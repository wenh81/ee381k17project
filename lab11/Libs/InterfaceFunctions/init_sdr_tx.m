%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init_sdr_tx.m
%
% sys_params_tx = init_sdr_tx(sys_params_base,varargin) generates the 
% default system parameters for a transmitter based on the input basic
% system parameter sys_params_base (struct array). It outputs a struct
% array containing the relevant information of the transmitter.
% 
% Passing customized system parameters is available using the following
% format: sys_params_base, 'property_name_1", value_1, "property_name_2", value_2, ...
% 
% --------------------List of tunable system parameters--------------------
% upsampling_factor: upsampling factor of the square root raised cosine (SRRC) filter for pulse shaping 
% roll_off: rolling factor of the SRRC filter for pulse shaping
% filt_spans: number of filter spans in symbols of the SRRC filter for pulse shaping
% usrp_ip_address: ip address of the transmitter USRP device
% usrp_sample_rate: transmitter sampling rate
% usrp_gain: transmitting gain of the USRP device in dB
% usrp_local_oscillator_offset: local oscillator offset of the usrp
% usrp_clock_source: source of frequency reference of the usrp
% usrp_pps_source : source of timing reference of the usrp
% total_frames_to_send : total number of frames to be sent
% --------------------List of tunable system parameters--------------------
%
%
% Created September 12, 2018 
% Robert W. Heath Jr.
% Yi Zhang
% The University of Texas at Austin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function sys_params_tx = init_sdr_tx(sys_params_base,varargin)
    %% Inherit basic parameters
    sys_params_tx = sys_params_base;
    
    %% Tunable transmitter parameters 
    % Pulse shaping parameters
    sys_params_tx.upsampling_factor = 4; % Upsampling factor
    sys_params_tx.roll_off = 0.5; % Roll-off factor of SRRC filter
    sys_params_tx.filt_spans = 10; % Filter span of square root raised cosine (SRRC) filter (in symbols)

    % Transmitter USRP hardware parameters
    sys_params_tx.usrp_ip_address = '192.168.10.2,192.168.10.3'; % USRP IP address 
    sys_params_tx.usrp_sample_rate = 5e6; % USRP baseband sample rate 
    sys_params_tx.usrp_gain = 10; % Transmitting gain
    sys_params_tx.usrp_local_oscillator_offset = 0; % Local oscillator offset
    sys_params_tx.usrp_clock_source = 'External';  % Source of frequency reference
    sys_params_tx.usrp_pps_source = 'Internal';    % Source of timing reference
    sys_params_tx.usrp_channelmapping = [1,2];
    sys_params_tx.total_frames_to_send = 1000000; % The total number of frames to send
    
    %% Customize the parameters according to input arguments (varargin)
    n_var_in = length(varargin);
    if mod(n_var_in,2) ~= 0
         error('Number of input arguments excluding "sys_params_base" should be even.')
        % Format for varargin: sys_params_base, 'property_name_1", value_1, "property_name_2", value_2, ...    
    else
        for k = 1 : 2 : n_var_in
            field_name = varargin{k};
            new_value = varargin{k+1};
            sys_params_tx.(field_name) = new_value;
        end
    end

    %% Dependent parameters (not tunable)
    sys_params_tx.usrp_interpolation_factor = sys_params_tx.usrp_master_clock_rate / sys_params_tx.usrp_sample_rate; % Receiving decimation factor
    sys_params_tx.usrp_samples_per_frame = sys_params_tx.upsampling_factor * sys_params_tx.frame_size; % Number of samples per frame to be sent. It should be noted that this value is different from transmitter and receiver as the receiver will buffer multiple frames.     
    sys_params_tx.T_sample = 1/sys_params_tx.usrp_sample_rate;  % Sample duration
    sys_params_tx.T_symbol = sys_params_tx.upsampling_factor * sys_params_tx.T_sample; % Symbol duration
    sys_params_tx.frame_time = sys_params_tx.usrp_samples_per_frame * sys_params_tx.T_sample; % Frame duration
    sys_params_tx.transmission_time = sys_params_tx.total_frames_to_send * sys_params_tx.frame_time; % Transmitting duration in seconds
   
    %% Order the fields of structure in ASCII dictionary order
    sys_params_tx = orderfields(sys_params_tx);
end
