%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% channel_simulator.m
%
% rx_sig_all = channel_simulator(frame_to_send,sys_params_rx) passes the 
% transmitted signal frame_to_send (column vector) into a simulated 
% channel with the parameters described in sys_params_rx (struct array).
% It outputs the corrupted received signal rx_sig_all (column vector). 
%
% Created September 12, 2018 
% Robert W. Heath Jr.
% Yi Zhang
% Kevin Joe
% The University of Texas at Austin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rx_sig_all = channel_simulator(frame_to_send,sys_params_rx,h)
    % Fetch parameters of the simulated channel
    channel_tap = reshape(sys_params_rx.channel_tap(h(1),h(2),:),[],1); % multiple channel versions
    channel_tap = upsample(channel_tap,10);
    
    channel_delay = sys_params_rx.channel_delay;
    %delay_in_samples = sys_params_rx.channel_delay_samples;
    channel_cfo = sys_params_rx.channel_cfo;
    channel_snr_dB = sys_params_rx.channel_snr_dB;
    Ts = sys_params_rx.T_sample;
    % Signal originally transmitted
    
    % how many frames to send ???
    rx_sig_all = repmat(frame_to_send,sys_params_rx.total_frames_to_receive,1);

    
    % Pass the signal through the channel
    rx_sig_all = conv(rx_sig_all,channel_tap);
%     % Add carrier frequency offset  %%%%% REMOVE FOR NOW %%%%%
    if sys_params_rx.sim_CF
        n = (0:1:length(rx_sig_all)-1)';
        cfo_coefs = exp(1j*2*pi*Ts*channel_cfo*n);
        rx_sig_all = rx_sig_all.*cfo_coefs; 
    end
        
    % Add delay   %%%%% REMOVE FOR NOW %%%%%
    
    if sys_params_rx.sim_delay
        delay_in_samples = round(channel_delay/Ts);  
        rx_sig_all = circshift(rx_sig_all, delay_in_samples);
    end
    
    
    % Add additive gaussian noise
    SNR = 10^(0.1*channel_snr_dB);
    gain = norm(channel_tap)^2;
    noise_var = gain/SNR;
    [r,c] = size(rx_sig_all);
    noise = sqrt(noise_var)*1/sqrt(2)*(randn(r,c)+randn(r,c)*1i);
    rx_sig_all = rx_sig_all + noise;
    % Remove undesired portion due to convolution
    L_remove = length(channel_tap)-1;
    rx_sig_all = rx_sig_all(1:end-L_remove);
end