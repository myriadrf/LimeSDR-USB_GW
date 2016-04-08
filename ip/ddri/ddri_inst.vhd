ddri_inst : ddri PORT MAP (
		aclr	 => aclr_sig,
		datain	 => datain_sig,
		inclock	 => inclock_sig,
		dataout_h	 => dataout_h_sig,
		dataout_l	 => dataout_l_sig
	);
