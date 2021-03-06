%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transmitter.m
%
% This is the main function for transmitting data
%
% Last Modified Dec. 20, 2018 
% Robert W. Heath Jr.
% Yi Zhang
% Kevin Joe
% The University of Texas at Austin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% paths
addpath(genpath([pwd '/stu_to_do']));
addpath(genpath([pwd '/Libs']));

%% Simulation parameters
M = 4;
payload_size_in_ofdm_symbols = 10;
sys_params_base = init_sdr('usrp_center_frequency', 2.40e9, ...
                           'sys_id',3, ...
                           'M',M, ...
                           'training_seq_name','Zadoff-Chu',... % Choose your desired training sequence: "Barker", "Zadoff-Chu", "Golay_32", "Golay_64"
                           'training_seq_repetition',2,... % Number of repetition of the trainig sequence
                           'N_ZC',52,... % Length of Zadoff-Chu sequence
                           'M_ZC',3,... % Co-prime parameter with N_ZF for generating Zadoff-Chu sequence
                           'M_ZC2',5,... % second co-prime number with 64
                           'L_P', 16,... % Length of prefix for training sequence
                           'N_carriers',64,... % Numer of DFT N
                           'L_CP',16, ... % Length of cyclic prefix for data
                           'N_tx',2, ...  % number of transmitter antennas
                           'N_rx',2);    % number of receiver antennas
                       
% System parameters for the transmitter                       
sys_params_tx = init_sdr_tx(sys_params_base,...
                           'usrp_sample_rate',5e6,... % USRP sampling rate
                           'usrp_gain',15,... %%%%%%%% USRP receiver gain %%%%%%%%
                           'upsampling_factor', 10,... % Upsampling factor
                           'roll_off', 0.5,... % Rolling factor
                           'filt_spans', 6,...  % Filter span of square root raised cosine (SRRC) filters (in symbols)
                           'downsampling_factor', 10,... % Downsampling factor
                           'usrp_channelmapping', 1:2);

%% Data generation 
% Step 1: generate random bit for transmission
%rng(1234)
bits_sent = randi([0 1], sys_params_tx.payload_size_in_bits, 1);
save bits_sent bits_sent; 

% Step 2: modulate the bit stream with QAM
qam_modulated_data = qam_mod(bits_sent, sys_params_tx.M);
save qam_modulated_data qam_modulated_data; 

% Step 3: generate the frame OFDM
ofdm_payload_symbols = OFDM_mod(qam_modulated_data, sys_params_tx);

% Step 4: Spatial Multiplex
multiplex = reshape(ofdm_payload_symbols,[],sys_params_tx.N_tx);

% Step 5: Add training data

%%%%% your preamble is added here %%%%%
framed_data = [sys_params_tx.OFDM_preamble; multiplex];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 6: Pulse Shaping

frame_to_send = [pulse_shaping(framed_data(:,1), sys_params_tx), ... 
                pulse_shaping(framed_data(:,2), sys_params_tx)];

% save the transmitted symbols for test with simulated channel 
type_frame_to_send = coder.newtype('double',[length(frame_to_send) 2],'complex',true);
save frame_to_send frame_to_send; 

%% Data transmission

compile_it = false;
use_codegen = false;
use_wireless_link = false; % true: test with real wireless link. false: test with simulated channel  
if compile_it
    codegen('run_usrp_tx', '-args', {coder.Constant(sys_params_tx),type_frame_to_send}); %#ok<UNRCH>
end
if use_wireless_link
    if use_codegen
       clear run_usrp_tx_mex %#ok<UNRCH>
       run_usrp_tx_mex(sys_params_tx,frame_to_send); 
    else
       run_usrp_tx(sys_params_tx,frame_to_send); 
    end
end
