

int test_2()
{

  //Tests all return 0 on success, non-zero on failure
  return 0;
}

//this macro runs the test, and returns the test number on failure
#define do_test(i) do{if ( test_##i () ) return i;}while(0)

int main()
{

  do_test(2);

  return 0;

}
