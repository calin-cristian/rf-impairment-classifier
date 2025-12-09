%% datasetAug.m — Augment QPSK dataset + show sample plots 
clear all; clc;

%% Load clean dataset
load('rxData_QPSK.mat');   % contains frames (Nsym × Nclean)
fprintf('Loaded %d clean frames\n', totalFrames);

frames_clean = frames;
Nsym   = size(frames_clean, 1);
Nclean = size(frames_clean, 2);

%% Augmentation parameters
snr_values     = [5];             
cfo_values     = [0.05 0.10 0.20];
phase_offsets  = [pi/6, pi/4, pi/3];
IQ_gains       = [0.1, 0.2, 0.3];
timing_taps    = [-1 1];

%% Storage cell arrays
X = {};
y = {};

%% Helper to append sample
function append_sample(sig, label, Xcell, Ycell)
    Xcell{end+1} = sig;
    Ycell{end+1} = label;
    assignin('caller','X',Xcell);
    assignin('caller','y',Ycell);
end

%% RRC filter
rrc = rcosdesign(0.5, 8, 2);

%% === Augmentation loop ===
for i = 1:Nclean
    x = frames_clean(:, i);

    % 0 — CLEAN
    append_sample(x, 0, X, y);

    % 1 — SINGLE LEVEL LOW SNR
    xn = awgn(x, snr_values, 'measured');
    append_sample(xn, 1, X, y);

    % 2 — CFO
    n = (0:Nsym-1).';
    for cfo = cfo_values
        x_cfo = x .* exp(1j * cfo * n);
        append_sample(x_cfo, 2, X, y);
    end

    % 3 — Static phase offset
    for ph = phase_offsets
        x_ph = x * exp(1j * ph);
        append_sample(x_ph, 3, X, y);
    end

    % 4 — Timing distortion
    for tap = timing_taps
        x_shift = conv(x, circshift(rrc, tap), 'same');
        append_sample(x_shift, 4, X, y);
    end

    % 5 — IQ imbalance
    for g = IQ_gains
        xi = real(x)*(1+g) + 1j*imag(x)*(1-g);
        append_sample(xi, 5, X, y);
    end
end

%% Convert to arrays
fprintf('Converting X,y to arrays...\n');

N_total = numel(X);
Xmat = zeros(Nsym, N_total);
for k = 1:N_total
    Xmat(:,k) = X{k};
end
yvec = int32(cell2mat(y));

%% Save dataset
save('datasetQPSK.mat', ...
    'Xmat','yvec','Nsym','N_total', ...
    'snr_values','cfo_values','phase_offsets','IQ_gains','timing_taps', ...
    '-v7.3');

fprintf('Saved augmented dataset in datasetQPSK.mat\n');

%% === Plot sample examples ===
fprintf('Generating visual examples...\n');

example_classes = 0:5;
titles = {
    '0 = Clean'
    '1 = Low SNR'
    '2 = CFO residual'
    '3 = Static phase offset'
    '4 = Timing distortion'
    '5 = IQ imbalance'
};

figure; clf;
for c = example_classes
    idx = find(yvec == c, 1);
    subplot(2,3,c+1);
    scatter(real(Xmat(:,idx)), imag(Xmat(:,idx)), 8, 'y', 'filled');
    axis equal;
    title(titles{c+1});
    xlabel('In-Phase'); ylabel('Quadrature');
    grid on;
end
sgtitle('Sample Augmentation Examples');
