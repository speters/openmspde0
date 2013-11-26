pmem0_inst : pmem0 PORT MAP (
		address	 => address_sig,
		byteena	 => byteena_sig,
		clken	 => clken_sig,
		clock	 => clock_sig,
		data	 => data_sig,
		wren	 => wren_sig,
		q	 => q_sig
	);
