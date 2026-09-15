% trainPredictiveAI.m
% AI Time-Series Forecasting for Factor of Safety (FS) Horizon

%% 1. Extract Telemetry & Calculate Effective Stress FS
tau = out.logsout.get('shear_stress').Values.Data;
pressure = out.logsout.get('pore_pressure').Values.Data;

% Physical parameters for 4.5m soil depth
total_normal_stress = 60000; % Approximate baseline normal stress in Pa

% Calculate Effective Normal Stress (total stress minus water pressure)
effective_stress = total_normal_stress - pressure;

% Prevent negative effective stress (soil liquefies at 0)
effective_stress(effective_stress < 0) = 0; 

% Dynamic FS: Starts at 1.3 and scales down as effective stress is lost
FS = 1.3 .* (effective_stress ./ total_normal_stress);

%% 2. Prepare Sequence Data for LSTM
XTrain = { [tau, pressure]' };

% THE FIX: Dynamically set the predictive horizon based on the dataset length
% Instead of a hardcoded 900 samples, look ahead by 15% of the simulation data
horizonOffset = round(length(FS) * 0.15); 

% Shift the target array and pad the end with the final FS value to match lengths
futureFS = [FS(horizonOffset+1:end); FS(end) * ones(horizonOffset, 1)];
YTrain = { futureFS' };

%% 3. Define the LSTM Network Architecture
numFeatures = 2; 
numResponses = 1; 
numHiddenUnits = 125; 

layers = [ ...
    sequenceInputLayer(numFeatures, 'Normalization', 'zscore', 'Name', 'Live_Telemetry_In')
    lstmLayer(numHiddenUnits, 'OutputMode', 'sequence', 'Name', 'LSTM_Core')
    fullyConnectedLayer(numResponses, 'Name', 'FS_Projection')
    regressionLayer('Name', 'Output_Horizon')];

%% 4. Configure Training Options
options = trainingOptions('adam', ...
    'MaxEpochs', 250, ...
    'GradientThreshold', 1, ...
    'InitialLearnRate', 0.005, ...
    'Plots', 'training-progress', ...
    'Verbose', 0);

%% 5. Train and Save the Predictive Model
disp('Training LSTM Network...');
predictiveNet = trainNetwork(XTrain, YTrain, layers, options);
save('predictiveModel.mat', 'predictiveNet');
disp('Model saved successfully as predictiveModel.mat!');