%% This code provides a methodology to partition a large battery test dataset into segments in order to derive relevent information from them. 
%% In this approach, the data is partitioned and binned in terms of SOC.
%% SOC is the State of Charge of a battery. It is the percentage amount of charge reminaing in the batery 
%% the entire range of SOC is divided in to 10 parts each being of 10%.

close all
clear all
clc

% The ten partitions for SOC is calculated at this step.
SOC_set = 0:10:100;
% The Total data length is calculated.
SOC_len = length(SOC_set); 

% Selection of directory in which a perticular battery's data set is
% located.
location = [uigetdir('pick directory with normalized .mat data'),'\'];
files_to_do = dir(location);

%filename formating
elim = 0;
for k=1:length(files_to_do)
    if isempty(strfind(files_to_do(k).name,'mat'))
        elim = elim+1;
        loose(elim) = k;
    end
end
files_to_do(loose) = [];
file_length = length(files_to_do);




%% Edit 1 
% Voltage, Current and Temperature data are partitioned based on the SOC
% ranges.

results = {};
for next=1:file_length
    tic
    file = files_to_do(next).name;
    fname = strcat(location, file);


    matname = dir('*.mat');
    load(matname(next).name);
    clear D1 loc

    D1(:,1) = D(:,1);    % Voltage (V)@ 10 Hz

    D1(:,2) = D(:,2);    % Current (I) @ 10 Hz

    D1(:,3) = D(:,3)*180;    % Temperature (T_batt) @ 10 Hz

    D1(:,6) = min(100, max(1, D(:,6)));    % SOC @ 10 Hz
    
%     sat = min(100, max(0, D1(:,6)));
    
    
    loc = find(isnan(D1(:,1))) ;  % Remove NaN values
    D1(loc,:) = [];

    %D1(1:250,:) = [];  % Remove first 250 data points

    D1(:,4) = (D1(:,2)*0.1)/3600;   %Ahr @ 10 Hz

    D1(:,5) = D1(:,1).*D1(:,4);   % Whr @ 10 Hz

    N = matname(next).name;

    clear D;

    test1_Ah = cell(1, 10);
    test1_Wh = cell(1, 10);
    test1_temp = cell(1, 10);
    test1_SOC = cell(1,10);
    test1_N = cell(1, 10);

    for i = 1:10
        temp = zeros(1, length(D1(:,1)));
        temp(:) = NaN;
        test1_Ah{i} = temp;
    end

    for i = 1:10
        temp = zeros(1, length(D1(:,1)));
        temp(:) = NaN;
        test1_Wh{i} = temp;
    end

    for i = 1:10
        temp = zeros(1, length(D1(:,1)));
        temp(:) = NaN;
        test1_temp{i} = temp;
    end
    
    for i = 1:10
        temp = zeros(1, length(D1(:,1)));
        temp(:) = NaN;
        test1_SOC{i} = temp;
    end

    for i = 1:10
        temp = zeros(1, length(D1(:,1)));
        temp(:) = NaN;
        test1_N{i} = temp;
    end
    counters = ones(1, 10);



    for i= 1:length(D1(:,2))

        bin_index = length(SOC_set(SOC_set < D1(i,6)));

        test1_Ah{bin_index}(counters(bin_index)) = D1(i,4);
        test1_Wh{bin_index}(counters(bin_index)) = D1(i,5);
        test1_temp{bin_index}(counters(bin_index)) = D1(i,3)/180;
        test1_SOC{bin_index}(counters(bin_index)) = D1(i,6);
       
        
        counters(bin_index) = counters(bin_index)+1;

    end
%     C = vertcat(test1_Ah,test1_Wh,test1_temp);

    %Remove NaN
    for j=1:length(test1_Ah)
        test1_Ah{j}(isnan(test1_Ah{j})) = [];
    end
    
    for j=1:length(test1_Wh)
        test1_Wh{j}(isnan(test1_Wh{j})) = [];
    end
    
    for j=1:length(test1_temp)
        test1_temp{j}(isnan(test1_temp{j})) = [];
    end
    
    for j=1:length(test1_SOC)
        test1_SOC{j}(isnan(test1_SOC{j})) = [];
    end
    
    
    tempStruct.Ah = test1_Ah;
    tempStruct.Wh = test1_Wh;
    tempStruct.T = test1_temp;
    tempStruct.SOC = test1_SOC;
    tempStruct.N = N;
    
    results{next} = tempStruct;
    toc
    
    clear D1 temp test1_Ah test1_Wh test1_temp test1_SOC test1_N
end
tic
save('Battery_name_matrix_SOC_binning.mat','results','-v7.3');
toc 

