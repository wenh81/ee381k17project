%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ofdm_preamble_generator.m
% function sys_params_base = ofdm_preamble_generator(sys_params_base)
%
% This function generates the preamble for OFDM systems and add relative
% properties to the basic system parameters sys_params_base, which is the
% base of the system parameters sys_params_tx and sys_params_rx
% 
% Input: 
%    sys_params_base is the common system parameters employed  
%
% Output
%    sys_params_base is the common system parameters employed  
%
%
% Last Modified Dec. 10, 2018
% Robert W. Heath Jr.
% Yi Zhang
% Kevin Joe
% The University of Texas at Austin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sys_params_base = ofdm_preamble_generator(sys_params_base)
        % Fetch parameters
        N_active_carriers = sys_params_base.N_active_carriers; % Generate Zadoff-Chu sequnce with length of active subcarriers
        if sys_params_base.training_seq_length ~= N_active_carriers
            zadoff_chu_training = exp(-(1i*sys_params_base.M_ZC*pi*[0:N_active_carriers-1]'.^2)/N_active_carriers);    
            sys_params_base.training_seq = zadoff_chu_training;
        end
        N_carriers = sys_params_base.N_carriers;  % Number of total subcarriers for SC-FDE and OFDM (N-DFT)
        active_carriers_index = sys_params_base.active_carriers_index;  % Number of active subcarriers
        N_tx = sys_params_base.N_tx; % Number of transmit antennas
            
%%%%%%% YOUR CODE GOES HERE %%%%%%%%%
% your task is to create the second ZC sequence and then prepare the time
% domain signal to be sent. Each entry in the cell corresponds to 1 antenna.
% Antenna 1
% sys_params_base.single_CE_freq_domain{1} = training sequence in frequency domain (column vector)
% sys_params_base.single_CE_time_domain{1} = training sequence in time domain (column vector)
% sys_params_base.OFDM_CE{1} = training sequence with cyclic prefix in time domain (column vector)
% 
% Antenna 2
% sys_params_base.single_CE_freq_domain{2} = ;
% sys_params_base.single_CE_time_domain{2} = ;
% sys_params_base.OFDM_CE{2} = ;

        % channel estimation field
        zadoff_chu_training = exp(-(1i*sys_params_base.M_ZC2*pi*[0:sys_params_base.N_ZC-1]'.^2)/sys_params_base.N_ZC);    
        sys_params_base.training_seq2 = zadoff_chu_training;
        
        for loop = 1:N_tx

            t = zeros(N_carriers,1);
            if loop == 1
                t(active_carriers_index+1) = sys_params_base.training_seq; % i think indices start at 0 ...
            else
                t(active_carriers_index+1) = sys_params_base.training_seq2;
            end

            L_P = sys_params_base.L_P;
            w = sqrt(N_carriers)*ifft(t,N_carriers);
            prefix = w(end-L_P+1:end);
            totalw = [prefix ; w]; 
        
            sys_params_base.single_CE_freq_domain{loop} = t; 
            sys_params_base.single_CE_time_domain{loop} = w;
            sys_params_base.OFDM_CE{loop} = totalw;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        sys_params_base.single_OFDM_training_seq_time_domain_length = N_carriers; 
        
       
        %%%% CFO ESTIMATION FRAME/FREQ SYNC %%%%%
        STF = wlan802_11a_STF_generator();
        preamble = [totalw; w];
        sys_params_base.OFDM_CFO = [STF; preamble] ;

        sys_params_base.STF_start = length(totalw)+1;
        sys_params_base.CEF_start = sys_params_base.STF_start + length(STF);
         
        sys_params_base.OFDM_preamble = [sys_params_base.OFDM_CE{1}, sys_params_base.OFDM_CE{2}; sys_params_base.OFDM_CFO,sys_params_base.OFDM_CFO];
        sys_params_base.OFDM_preamble_length = length(sys_params_base.OFDM_preamble);
        sys_params_base.data_start = length(sys_params_base.OFDM_preamble)+1;
        
end

function STF = wlan802_11a_STF_generator()
    L_CP = 16; % Fixed CP length 
    N_carriers = 64; % Fixed Number of carriers
    % In the 20 MHz transmission mode: the legacy short training OFDM symbol 
    % are assigned to subcarriers -24, -20, -16, -12, -8, -4, 4, 8, 12, 16, 20, 24.
    % Check http://rfmw.em.keysight.com/wireless/helpfiles/n7617a/n7617a.htm#legacy_short_training_field.htm
    subcarriers_stf = [4:4:24 [-24:4:-4]+64]; % This index number start from 0, it is from 0 to 63
    
    % code here
    seq = [ -1-1j; -1-1j; 1+1j; 1+1j; 1+1j; 1+1j; 1+1j; -1-1j; 1+1j; -1-1j; -1-1j; 1+1j];
    tmp = zeros(N_carriers,1);
    tmp(subcarriers_stf+1) = seq;
    stf_symbol = ifft(tmp,N_carriers)*sqrt(64);
    STF = repmat(stf_symbol(1:L_CP),10,1);
end
