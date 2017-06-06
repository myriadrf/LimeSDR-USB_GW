#!/usr/bin/python
import sys
import shlex
import shutil
import os
import subprocess
import re
import time
import threading
import multiprocessing
###########################################################################
def pushd(dirname):
    class PushdContext:
        def __init__(self, dirname):
            self.cwd = os.path.realpath(dirname)
        def __enter__(self):
            self.original_dir = os.getcwd()
            os.chdir(self.cwd)
            return self
        def __exit__(self, type, value, tb):
            os.chdir(self.original_dir)

    return PushdContext(dirname)


QUEUES=("main.q",)
QUEUES=("main.q@altivec","main.q@asc","main.q@avx","main.q@cray1","main.q@mmx")#avoid star100
QUEUES=" ".join(map( lambda x : "-q "+ x,QUEUES))


class system:
    files_needed=("Makefile",
                  "riscv_test.vhd",
                  "system.qpf",
                  "system.qsf",
                  "system.qsys",
                  "system.sdc",
                  "rtl",
                  'interrupt_generator_hw.tcl',
                  'long_load_store_hw.tcl',
                  'pipeline_counter_hw.tcl',
                  'read_pipeline_hw.tcl',
                  'test_components')
    dirs=[]
    class duplicate_dir(Exception):
        pass
    def __init__(self,
                 branch_prediction,
                 btb_size,
                 divide_enable,
                 counter_length,
                 multiply_enable,
                 pipeline_stages,
                 shifter_max_cycles):
        self.branch_prediction=branch_prediction
        self.btb_size=btb_size
        self.divide_enable=divide_enable
        self.counter_length=counter_length
        self.multiply_enable=multiply_enable
        self.pipeline_stages=pipeline_stages
        self.shifter_max_cycles=shifter_max_cycles
        self.dhrystones=""
        self.directory=("./de2-115_"+
                        "bp%s_"+
                        "btbsz%s_"+
                        "div%s_"+
                        "mul%s_"+
                        "count%s_"+
                        "pipe%s_"+
                        "smc%s") %(self.branch_prediction,
                                   self.btb_size if self.branch_prediction == "true" else "0" ,
                                   self.divide_enable,
                                   self.multiply_enable,
                                   self.counter_length,
                                   self.pipeline_stages,
                                   self.shifter_max_cycles)

        if self.directory in system.dirs:
            raise system.duplicate_dir;
        else:
            system.dirs.append(self.directory)

    def create_build_dir(self ):
        try:
            os.mkdir(self.directory)
        except:
            pass
        for f in system.files_needed :
            if os.path.isdir("de2-115/"+f) :
                if not os.path.isdir(self.directory+"/"+f):
                    shutil.copytree("de2-115/" + f, self.directory+"/"+f)
            else:
                shutil.copy2("de2-115/"+f,self.directory)

        open(self.directory+"/test.hex","w")

        with open(self.directory+"/config.mk","w") as f:
            f.write('BRANCH_PREDICTION="%s"\n'   %self.branch_prediction)
            f.write('BTB_SIZE="%s"\n'            %self.btb_size)
            f.write('MULTIPLY_ENABLE="%s"\n'     %self.multiply_enable)
            f.write('DIVIDE_ENABLE="%s"\n'       %self.divide_enable)
            f.write('COUNTER_LENGTH="%s"\n'    %self.counter_length)
            f.write('PIPELINE_STAGES="%s"\n'     %self.pipeline_stages)
            f.write('SHIFTER_MAX_CYCLES="%s"\n'%self.shifter_max_cycles)
    def build(self,use_qsub=False,build_target="all",name="de2_115"):
        make_cmd='make -C %s %s'%(self.directory,build_target)
        if use_qsub:
            qsub_cmd='qsub %s -b y -o %s -sync y -j y  -V -cwd -N "%s" '% (QUEUES, self.directory +"/build.log",name) + make_cmd
            proc=subprocess.Popen(shlex.split(qsub_cmd))
        else:
           proc=subprocess.Popen(shlex.split(make_cmd))
           proc.wait()
        return proc

    def run_dhrystone_sim(self,qsub):
        proc=subprocess.Popen(['true'])
        def replace(x,y):
            with open("system/simulation/system.vhd") as f:
                string=re.sub(x+r"\s*=> [0-9]+",x+" => "+y,f.read())
            with open("system/simulation/system.vhd","w") as f:
                f.write(string)


        with pushd(self.directory):
            #these are modified versions of the benchmarks found in the riscv-test
            #repository. they only run 5 loops, all printf calls and setStats calls
            #are removed, and usertime is written to a gpio called hex0
            if self.multiply_enable == '1' :
                hex_file="../dhrystone.riscv.rv32im.qex"
            else:
                hex_file="../dhrystone.riscv.rv32i.qex"

            if not os.path.exists(hex_file):
                self.dhrystones="No Hex File"
                return proc

            if os.path.exists("system/simulation"):
                shutil.rmtree("system/simulation")
            shutil.copytree("../sim/system/simulation","system/simulation")


            shutil.copy(hex_file,"system/simulation/mentor/test.hex")

            replace('BRANCH_PREDICTORS',self.btb_size if self.branch_prediction == "true" else '0')
            replace('MULTIPLY_ENABLE',self.multiply_enable)
            replace('DIVIDE_ENABLE',self.divide_enable)
            replace('COUNTER_LENGTH',"64" if self.counter_length == "0" else self.counter_length)
            replace('PIPELINE_STAGES',self.pipeline_stages)
            replace('SHIFTER_MAX_CYCLES',self.shifter_max_cycles)
            vsim_tcl=("do ../tools/runsim.tcl",
                      "add wave /system/hex_0_external_connection_export",
                      "restart -f",
                      "onbreak {resume}",
                      "when {/system/hex_0_external_connection_export /= x\"00000000\" } {stop}",
                      "puts [exec hostname ]",
                      "run 10 us",
                      "puts \" User Time = [examine -decimal /system/hex_0_external_connection_export ] \"",
                      "puts \"Now = $now\"",
                      "exit -f")
            with open("dhrystone.tcl","w") as f:
                f.write("\n".join(vsim_tcl))

            vsim_tcl=";".join(vsim_tcl)
            vsim_cmd="vsim -c -do dhrystone.tcl| tee dhrystone_sim.out"

            if qsub:
                queues=shlex.split(QUEUES)
                split_cmd=["qsub",]+queues+["-b","y","-sync","y","-j","y","-V","-cwd","-N","dsim",vsim_cmd]
                proc=subprocess.Popen(split_cmd)
            else:
               subprocess.call(vsim_cmd,shell=True)
            return proc

    def get_dhrystone_stats(self):
        out_file=self.directory+"/dhrystone_sim.out"
        if os.path.exists(out_file):
            out=open(out_file).read()
            user_time=re.findall(r"User Time = ([0-9]+)",out)[0]
            self.dhrystones=user_time
        return


    def get_build_stats(self):
        timing_rpt=self.directory+"/output_files/system.sta.rpt"
        synth_rpt = self.directory+"/output_files/system.map.rpt"
        fit_rpt=self.directory+"/output_files/system.fit.rpt"
        self.fmax=-1
        self.cpu_prefit_size=-1
        self.cpu_postfit_size=-1
        if os.path.exists(timing_rpt):
            with open(timing_rpt) as f:
                rpt_string = f.read()
                fmax=re.findall(r";\s([.0-9]+)\s+MHz\s+;\s+clock_50",rpt_string)
                fmax=min(map(lambda x:float(x) , fmax))
                self.fmax=fmax
        if os.path.exists(synth_rpt):
            with open(synth_rpt) as f:
                rpt_string = f.read()
                self.cpu_prefit_size=int(re.findall(r"^;\s+\|Orca:vectorblox_orca_0\|\s+; (\d+)",rpt_string,re.MULTILINE)[0])
        if os.path.exists(fit_rpt):
            with open(fit_rpt) as f:
                rpt_string = f.read()
                self.cpu_postfit_size=int(re.findall(r"^;\s+\|Orca:vectorblox_orca_0\|\s+; (\d+)",rpt_string,re.MULTILINE)[0])
        with open(self.directory+"/summary.txt","w") as f:
            f.write('BRANCH_PREDICTION="%s"\n'   %self.branch_prediction)
            f.write('BTB_SIZE="%s"\n'            %self.btb_size)
            f.write('DIVIDE_ENABLE="%s"\n'       %self.divide_enable)
            f.write('COUNTER_LENGTH="%s"\n'    %self.multiply_enable)
            f.write('MULTIPLY_ENABLE="%s"\n'     %self.counter_length)
            f.write('SHIFTER_MAX_CYCLES="%s"\n'%self.shifter_max_cycles)
            f.write( "fmax=%f\n"                 %self.fmax)
            f.write( "cpu_prefit_size=%d\n"      %self.cpu_prefit_size)
            f.write( "cpu_postfit_size=%d\n"     %self.cpu_postfit_size)

chart_script="""
function insert_chart(element_select,data) {


	 var margin = {top: 20, right: 15, bottom: 60, left: 60}
	 , width = 960 - margin.left - margin.right
	 , height = 500 - margin.top - margin.bottom;

         var xmin = d3.min(data, function(d) { return d[0]; });
         var xmax = d3.max(data, function(d) { return d[0]; });
         var xmarg = (xmax -xmin)*0.05;
         var xmin = xmin - xmarg
         var xmax = xmax + xmarg
	 var x = d3.scale.linear()
		  .domain([xmin,xmax])
		  .range([ 0, width ]);

         var ymin = d3.min(data, function(d) { return d[1]; });
         var ymax = d3.max(data, function(d) { return d[1]; });
         var ymarg = (ymax -ymin)*0.05;
         var ymin = ymin - ymarg
         var ymax = ymax + ymarg


	 var y = d3.scale.linear()
		  .domain([ymin,ymax])
		  .range([ height, 0 ]);

	 var chart = d3.select(element_select)
		  .append('svg:svg')
		  .attr('width', width + margin.right + margin.left)
		  .attr('height', height + margin.top + margin.bottom)
		  .attr('class', 'chart')

	 var main = chart.append('g')
		  .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
		  .attr('width', width)
		  .attr('height', height)
		  .attr('class', 'main')

	 // draw the x axis
	 var xAxis = d3.svg.axis()
		  .scale(x)
		  .orient('bottom');

	 main.append('g')
		  .attr('transform', 'translate(0,' + height + ')')
		  .attr('class', 'main axis date')
		  .call(xAxis);

	 // draw the y axis
	 var yAxis = d3.svg.axis()
		  .scale(y)
		  .orient('left');

	 main.append('g')
		  .attr('transform', 'translate(0,0)')
		  .attr('class', 'main axis date')
		  .call(yAxis);

	 var g = main.append("svg:g");

	 g.selectAll("scatter-dots")
		  .data(data)
		  .enter().append("svg:circle")
		  .attr("cx", function (d,i) { return x(d[0]); } )
		  .attr("cy", function (d) { return y(d[1]); } )
		  .attr("r", 8)
		  .attr("class", function (d) { return d[2].split("_").slice(2).join(" "); } )
		  .append("svg:title").text(  function (d,i) { return d[2] } );
}
"""

check_boxes_html="""
<div >
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="btbsz0">    btbsz0      </input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="btbsz1">    btbsz1		</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="btbsz16">   btbsz16		</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="btbsz256">  tbsz256	</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="btbsz4096"> btbsz4096</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="div1">      div1				</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="mul1">      mul1				</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="count0"> count0		</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="count32">count32		</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="count64">count64		</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="pipe4">     pipe4			</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="smc1">      smc1				</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="smc8">      smc8				</input>
<input class="red-selector" type="checkbox"  onchange="toggle_checkbox(this)" name="smc32">     smc32				</input>
<script>
function toggle_checkbox(k) {

   var name =  d3.select(k).attr("name");
   var sel = d3.selectAll("."+name);
   if (d3.select(k).property("checked")){
      sel.style("fill","red");
   }else{
      sel.style("fill","steelblue");
   }
}
</script>
</div>
"""

def summarize_stats(systems):
    try:
        os.mkdir("summary")
    except:
        pass
    with open("summary/summary.html","w") as html:
        html.write("\n".join(("<!DOCTYPE html>",
                              "<html>",
                             "<head>",
                              "<title>Comparison of different build configurations</title>",
                              '<meta charset="UTF-8"> ',
                              '<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>',
                              '<script src="http://code.jquery.com/ui/1.11.3/jquery-ui.js"></script>',
                              '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">',
                              '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>'

                              #'<script src="http://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>',
                              '<script src="http://tablesorter.com/__jquery.tablesorter.min.js"></script>',
                              '<script type="text/javascript" src="http://mbostock.github.com/d3/d3.v2.js"></script>',

                              '<script >%s</script>'%chart_script,
                              "<style>                       ",
                              "	.chart {                     ",
                              "                              ",
                              "	}                            ",
                              "                              ",
                              "	.main text {                 ",
                              "	font: 10px sans-serif;       ",
                              "	}                            ",
                              "                              ",
                              "	.axis line, .axis path {     ",
                              "	shape-rendering: crispEdges; ",
                              "	stroke: black;               ",
                              "	fill: none;                  ",
                              "	}                            ",
                              "	circle {                     ",
                              "	fill: steelblue;             ",
                              "	}                            ",
                              "</style>                      ",
                              "<script>  ",
                              "  $(document).ready(function(){      ",
                              '      var tbl = $(".tablesorter");',
                              "      tbl.tablesorter() ",
                              "    $('.remove-row').click(function(){ ",
                              '       $($(this).closest("tr")).remove();',
                              "    });                              ",
                              "  });                                ",
                              "</script>                            ",
                              "</head>",
                              "<body>",
                              "<h2>Comparison of different build configurations</h2><br>\n",
                              "<table class=\"table table-striped table-bordered table-hover tablesorter\" style=\"text-align:center\">")))

        html.write("<thead><tr>")
        for th in ('','','branch prediction','btb size','multiply','divide',
                   'perfomance counters','pipeline stages','single max cycles','prefit size','postfit size','FMAX','DMIPS','DMIPS/MHz','DMIPS/1000LUT (post-fit)'):
            html.write('<th>%s</th>'%th)
        html.write("</tr></thead><tbody>\n")
        dhry_data=[]
        fmax_data=[]
        for sys in systems:
            try:
                fmax_data.append([sys.cpu_postfit_size,sys.fmax,sys.directory])
                dmips_per_mhz=((5*1000000./1757)/int(sys.dhrystones))
                dmips=dmips_per_mhz*sys.fmax
                dmips_per_lut=dmips*1000/sys.cpu_postfit_size;
                dhry_data.append([sys.cpu_postfit_size,1000./dmips,sys.directory])

                dmips_per_mhz="%.3f" % dmips_per_mhz
                dmips="%.3f"% dmips
                dmips_per_lut="%.3f"% dmips_per_lut

            except Exception as e:
                dmips_per_mhz=""
                dmips=""
                dmips_per_lut=sys.dhrystones


            button_html='<button class="btn btn-default remove-row"><span class="glyphicon glyphicon-remove" aria-hidden=true></span></button>'
            html.write("<tr>")
            html.write("<td>%s</td>" % button_html)
            html.write("<td>%s</td>"%str(sys.directory))
            html.write("<td>%s</td>"%str(sys.branch_prediction))
            html.write("<td>%s</td>"%str(sys.btb_size if sys.branch_prediction == "true" else "N/A"))
            html.write("<td>%s</td>"%str(sys.multiply_enable))
            html.write("<td>%s</td>"%str(sys.divide_enable))
            html.write("<td>%s</td>"%str(sys.counter_length))
            html.write("<td>%s</td>"%str(sys.pipeline_stages))
            html.write("<td>%s</td>"%str(sys.shifter_max_cycles if sys.multiply_enable == "0" else "N/A"))
            html.write("<td>%s</td>"%str(sys.cpu_prefit_size))
            html.write("<td>%s</td>"%str(sys.cpu_postfit_size))
            html.write("<td>%s</td>"%str(sys.fmax))
            html.write("<td>%s</td>"%str(dmips))
            html.write("<td>%s</td>"%str(dmips_per_mhz))
            html.write("<td>%s</td>"%str(dmips_per_lut))

            html.write("</tr>\n")
        html.write("</tbody></table>\n")
        html.write(check_boxes_html);
        def add_chart(title,data):
            id=hash(title)
            id = id if id >0 else -id
            if len(data):
                html.write("<div id=\"id_%x\"><h3>%s</h3></div>\n" % (id,title))
                html.write("<script>\n insert_chart(\"#id_%x\",%s);\n</script>" % (id,str(data)))
        add_chart("LUT Count vs Execution Time (1000/DMIPS)",dhry_data)
        add_chart("LUT Count vs FMax", fmax_data)
        html.write("</body></html>\n")

SYSTEMS=[]

if 0:
    SYSTEMS=[ system(branch_prediction="false",
                     btb_size="1",
                     divide_enable="0",
                     multiply_enable="0",
                     counter_length="32",
                     shifter_max_cycles="32",
                     pipeline_stages="4"),
              system(branch_prediction="false",
                     btb_size="1",
                     divide_enable="0",
                     multiply_enable="0",
                     counter_length="0",
                     shifter_max_cycles="0",
                     pipeline_stages="4"),
              system(branch_prediction="true",
                     btb_size="4096",
                     divide_enable="0",
                     multiply_enable="0",
                     counter_length="0",
                     shifter_max_cycles="0",
                     pipeline_stages="4"),
              system(branch_prediction="true",
                     btb_size="256",
                     divide_enable="0",
                     multiply_enable="0",
                     counter_length="0",
                     shifter_max_cycles="0",
                     pipeline_stages="4"),
              system(branch_prediction="false",
                     btb_size="1",
                     divide_enable="0",
                     multiply_enable="0",
                     counter_length="0",
                     shifter_max_cycles="1",
                     pipeline_stages="4"),
              system(branch_prediction="true",
                     btb_size="256",
                     divide_enable="0",
                     multiply_enable="0",
                     counter_length="0",
                     shifter_max_cycles="0",
                     pipeline_stages="5"),
              system(branch_prediction="false",
                     btb_size="256",
                     divide_enable="1",
                     multiply_enable="1",
                     counter_length="0",
                     shifter_max_cycles="0",
                     pipeline_stages="5"),
              system(branch_prediction="true",
                     btb_size="4096",
                     divide_enable="1",
                     multiply_enable="1",
                     counter_length="1",
                     shifter_max_cycles="0",
                     pipeline_stages="5"),
              system(branch_prediction="false",
                     btb_size="256",
                     divide_enable="1",
                     multiply_enable="1",
                     counter_length="0",
                     shifter_max_cycles="0",
                     pipeline_stages="4"),
              system(branch_prediction="true",
                     btb_size="4096",
                     divide_enable="1",
                     multiply_enable="1",
                     counter_length="1",
                     shifter_max_cycles="0",
                     pipeline_stages="4"),

      ]
else:

    for bp in ["false"]:
        for btb_size in ["1","16","256","4096"]:
            if bp== "false" and btb_size != "1":
                continue;
            for mul in ["0","1"]:
                for div in ["0","1"]:
                    if div == "1" and mul == '0':
                        continue;
                    for ic in ["0","32","64"]:
                        for smc in ["1","8","32"]:
                            if mul == '1' and smc != '1':
                                continue;
                            for ps in ["4","5"]:
                                SYSTEMS.append(system(branch_prediction=bp,
                                                      btb_size=btb_size,
                                                      divide_enable=div,
                                                      multiply_enable=mul,
                                                      counter_length=ic,
                                                      shifter_max_cycles=smc,
                                                      pipeline_stages=ps))



if __name__ == '__main__':

    import argparse
    parser=argparse.ArgumentParser()
    parser.add_argument('-s','--stats-only',dest='stats_only',action='store_true',default=False)
    parser.add_argument('-d','--skip-dhrysone',dest='skip_dhrystone',action='store_true',default=False)
    parser.add_argument('-n','--no-stats',dest='no_stats',action='store_true',default=False)
    parser.add_argument('-t','--build-target',dest='build_target',default='all',help='Target to run with make command')
    parser.add_argument('-q','--no-qsub',dest='use_qsub',action='store_false',default=True, help='Use grid-engine to build systems')
    parser.add_argument('-m','--max-jobs',dest='max_jobs',action='store',type=int,default=25, help='max grid-engine jobs to run concurrently')
    args=parser.parse_args()

    devnull=open(os.devnull,"w")

    if not os.path.exists('sim/system_avalon/simulation/system.vhd'):
        with pushd('sim'):
            print "generating simulation files"
            subprocess.call( "make all",shell=True,
                                       stdout=devnull,stderr=devnull)

    for s in SYSTEMS:
        s.create_build_dir()

    def evaluate_system(sys):
        i,s = sys
        processes=[]
        if not args.stats_only:
            print "Submitting job %d/%d"%(i,len(SYSTEMS))
            processes.append(s.build(args.use_qsub,args.build_target,name="de2-115 %d of %d"%(i,len(SYSTEMS))))
        if not args.no_stats and not args.skip_dhrystone:
            processes.append(s.run_dhrystone_sim(args.use_qsub))
        [ p.wait() for p in processes]
    process_pool=multiprocessing.Pool(args.max_jobs)

    processes=process_pool.map(evaluate_system,enumerate(SYSTEMS,1))

    for s in SYSTEMS:
        if not args.no_stats:
            s.get_build_stats()
            s.get_dhrystone_stats()
    if not args.no_stats:
        summarize_stats(SYSTEMS)
