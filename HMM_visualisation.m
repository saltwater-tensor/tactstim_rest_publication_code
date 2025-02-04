%% Visualisation tools

model_path = 'Q:\tactstim_resting\code\tactstim_rest_models\';
model_name = '_04_Feb_2022_17_04_27_HMM_model_preStim_rest_250Hz.mat';
dataset_path = 'Q:\tactstim_resting\code\tactstim_rest_data\';
mdl_nm = strsplit(model_name,'.');
mdl_nm = mdl_nm{1};
spectral_output_name = 'nnmf_profiles_and_group_projections_3';

% For coherence and PSD values on a subject level and group level
load([model_path mdl_nm '_spectral_analysis' '\' spectral_output_name '.mat']);

% For significance permutation level single trial or subject level test
% results

% If it is a trial by trial experiment preferably have significance level
% results from single trial levle permutation testing

significance_test_results = 'HMM_trial_spectra_proj_PSD_permutation_test_within_state_results_2.mat';

load([model_path mdl_nm '_spectral_analysis' '\' spectral_output_name...
    '\' significance_test_results])

output_path_spectral_figs = ...
    'Q:\tactstim_resting\code\tactstim_rest_models\_04_Feb_2022_17_04_27_HMM_model_preStim_rest_250Hz_spectral_analysis\nnmf_profiles_and_group_projections_3\0.001_with_power_nodes\';

%% Add necessary helper code
addpath(genpath('Q:\software\OHBA_libs'));

%% CREATING FIGURES
% Load default anatomy by changing the path
load('Q:\tactstim_resting\New folder\brainstorm_db\tactstim_resting\anat\@default_subject\tess_cortex_pial_low')
atlas_name = 'Mindboggle';
atlas_number = 6;
if ~strcmpi(atlas_name,Atlas(atlas_number).Name)
   error('Check for valid atlas number') 
end
ROIs = [3,4,5,6,11,12,15,16,19,20,21,22,23,24,25,26,27,28,29,30,...
    33,34,35,36,37,38,41,42,45,46,47,48,51,52,53,54,55,56,57,58,59,60];
myLabel = cell(length(ROIs));
for i =1:1:length(ROIs)
  myLabel{i} = Atlas(atlas_number).Scouts(ROIs(i)).Label;
end

total_parcellations = 12;

% Original ROI indices
contacts = [1,2,3,4,5,6];
contacts_right = [1,2,3];
contacts_left = flip([4,5,6]);

frontal = [7,8,11,12,21,22,23,24,25,26,33,34,35,36];
frontal_right = [8,12,22,24,26,34,36];
frontal_left = flip([7,11,21,23,25,33,35]);

medial_PFC = [1,2,15,16];
medial_PFC_right = [2,16];
medial_PFC_left = flip([1,15]);

temporal = [17,18,39,40];
temporal_right = [18,40];
temporal_left = flip([17,39]);

sensory_motor = [27,28,29,30];
sensory_motor_right = [28,30];
sensory_motor_left = flip([27,29]);

parietal = [5,6,19,20,31,32,37,38,41,42];
parietal_right = [6,20,32,38,42];
parietal_left = flip([5,19,31,37,41]);


visual = [3,4,9,10,13,14];
visual_right = [4,10,14];
visual_left = flip([3,9,13]);

re_ROIs = [visual_right,parietal_right,sensory_motor_right,temporal_right,medial_PFC_right,frontal_right,frontal_left,medial_PFC_left,temporal_left,sensory_motor_left,parietal_left,visual_left];
parc_lengths = [length(contacts_right),length(visual_right),length(parietal_right),length(sensory_motor_right),...
                        length(temporal_right),...
                       length(medial_PFC_right),length(frontal_right),length(frontal_left),length(medial_PFC_left),...
                        length(temporal_left),length(sensory_motor_left),length(parietal_left),length(visual_left),...
                        length(contacts_left)];

parc_color_nums = [1,7,6,5,4,3,2,2,3,4,5,6,7,1];
% Original indices of the Atlas Scouts
re_ROIs_2 = ROIs(re_ROIs);
% Create custom node labels
myLabel_2 = cell(length(re_ROIs) + 6);

for i = 1:3
      myLabel_2{i} = ['contact_right' num2str(i)];
end
for i = 46:48
    myLabel_2{i} = ['contact_left' num2str(i)];
end
for i =4:1:45
  myLabel_2{i} = Atlas(atlas_number).Scouts(re_ROIs_2(i-3)).Label;
end
% Indices in the 48x48 matrix
re_ROIs_48_index = re_ROIs + 6;
re_ROIs_48_index_complete = [1:3,re_ROIs_48_index,4:6];
re_ROIs_42_index_complete = re_ROIs;

%% Node colors for schemaball
% 48 X 3
colors = lines(7);
colr_mat_2 = zeros(48,3);
begin_index = 1;
for tp = 1:(total_parcellations + 2)
    colr_mat_2(begin_index:begin_index+parc_lengths(tp)-1,:) = repmat(colors(parc_color_nums(tp),:),[length(begin_index:begin_index+parc_lengths(tp)-1),1]);
    begin_index = begin_index + parc_lengths(tp);
end
colr_mat_2_orig = colr_mat_2;

%% RING AND GLASS BRAIN PLOTS

%% For gmm based significance testing

% This is a cluster level test
% Selecting significant connections
gmm_test = input('Enter yes to plot gmm testing results');
freq_vals = fitmt_subj_fact_4b{1, 1}.state(1).f;
C = plot(freq_vals,supply_profiles(:,2:end),'LineWidth',5);
plot4paper('freq','nnmf weights')
legend
figstring = [output_path_spectral_figs 'nnmf profiles'];
% savefig(C,figstring)
% saveas(C,figstring,'png');

% remove_band = input('Enter supply profile to remove');
switch gmm_test
    case 'yes'
        fit_bands = fitmt_group_fact_4b;
        P_VALUE = input('enter your desired p-value for testing');
        
        K = size(fit_bands.state,2);
        ndim = size(fit_bands.state(1).coh,2);
        total_band_num = size(fit_bands.state(1).coh,1);  
        mask_connections = 0;
        within_state = 0;
        threshold = 1;
        fitmt_group_fact = fit_bands;
        % fitmt_group_fact = fit_bands;
        % Mean activation/coherence across all states
        if total_band_num == 1
            Band_tag = 'Wideband';
            M = zeros(ndim);
            M_psd = zeros(ndim);
            for k = 1:K
                M = M + squeeze(abs(fitmt_group_fact_4b.state(k).coh(1,:,:))) / K;
                M_psd = M_psd + squeeze(abs(fitmt_group_fact.state(k).psd(1,:,:))) / K;        
            end
        end 
        
        % if (total_band_num ~= (size(fitmt_group_fact.state(1).coh,1) - 1))
        %     error('The number of bands and the fitmt group loaded does not match')
        % end
        
        for k = 1:1:K
        
          for band = 1:1:total_band_num 
                
                % WITHIN A BAND BUT FOR ALL STATES FOR THIS BAND
                if total_band_num > 1
                    Band_tag = 'Fourband';
                    M = zeros(ndim);
                    M_psd = zeros(ndim);
                    % Mean activation/coherence across all states
                    if ~within_state
                    for k1 = 1:K
                        M = M + squeeze(abs(fitmt_group_fact.state(k1).coh(band,:,:))) / K;
                        M_psd = M_psd + squeeze(abs(fitmt_group_fact.state(k1).psd(band,:,:))) / K;
                    end
                    end
                    if within_state
                    
                    M = zeros(ndim);
                    M_psd = zeros(ndim);
                    % Within this state(k) taking mean across all the bands.
                    % We will subtract this mean from the connections across all states
                    % and plot the connections
                    for band1 = 1:total_band_num
                        M = M + squeeze(abs(fitmt_group_fact.state(k).coh(band1,:,:))) / total_band_num;
                        M_psd = M_psd + squeeze(abs(fitmt_group_fact.state(k).psd(band1,:,:))) / total_band_num;
                    end
                    end
                end    
                
                coherence_value = squeeze(abs(fitmt_group_fact.state(k).coh(band,:,:))); 
                
                % PSD controls the size of the schemaball nodes
                
                % PSD control type 1
                % No significance test based control
                % Subtracting the mean PSD calculated across states or within
                % states for the psd values for the current state and the band
                psd_amp_centered = diag(squeeze(fitmt_group_fact.state(k).psd(band,:,:))) - diag(M_psd);
%                 schemaball_size = 100*psd_amp_centered;
                
                % PSD control type 2
                % If using single trial level psd testing whether across
                % states or within states OR across different response
                % types has been performed then we can implement this other
                % type of PSD node control
                % Load the significance test outcome (Check section 1)
                
                % We cannot plot single trial level results or subject
                % level results 
                % Averaging creates bias so instead use the weighted
                % average results stored in the group level projection
                psd_scatter_value = diag(squeeze(fitmt_group_fact.state(k).psd(band,:,:)));
                psd_scatter_color = ring_visualisation_psd_control_2(psd_scatter_value,tests,k,band);
                
                % Non PSD controlled schemaball size
                schemaball_size = 20*ones(ndim,1);
                [r_schm,c_schm] = find(schemaball_size <= 0);
                colr_mat_2_schm = colr_mat_2_orig;
                
                
                
                
                % Coherence values for connectivity plot
                graph = coherence_value;        
                %Subtract the mean across states from the current state
                %coherence matrix
                graph = (graph - M);  
                if mask_connections
                    mask = NaN(ndim,ndim);
                    mask(lfp_pos(1):lfp_pos(2),cortex(1):cortex(2)) = ...
                    ones(length(lfp_pos(1):lfp_pos(2)),...
                    length(cortex(1):cortex(2)));
                    mask(cortex(1):cortex(2),lfp_pos(1):lfp_pos(2)) = ...
                    ones(length(cortex(1):cortex(2)),length(lfp_pos(1):lfp_pos(2))...
                    );
                    graph = graph.*mask;
                end
                    tmp = squash(tril(graph));
                    inds2 = find(tmp>1e-10);
                    %             inds2 = find(abs(tmp) >1e-10);
                    data = tmp(inds2);
                if ~exist('mask','var')
                    mask = ones(ndim,ndim);
                end
                if (~isempty(data) && (length(find(mask == 1)) > 36 ) && threshold)

                    S2 = [];
                    S2.data = data;
                    S2.do_fischer_xform = false;
                    S2.do_plots = 1;
                    S2.pvalue_th = P_VALUE/length(S2.data); %(Division corrects for multiple corrections)
                    try
                        graph_ggm = teh_graph_gmm_fit(S2); 
                    catch
                        try_catch_schemaball
                        continue
                    end
                    th = graph_ggm.normalised_th;
                    graph = graph_ggm.data';
                    graph(graph<th) = NaN;
                    graphmat = zeros(ndim, ndim);
                    graphmat(inds2) = graph;
                    graph = graphmat;

                else
                if threshold
                    graphmat = NaN(ndim, ndim);
                    graph(graph < 0 | graph == 0) = 0;
                    graph(21,22) = 0.05;
                end
                    graph(graph < 0 | graph == 0) = 0;
                end
                    graph(isnan(graph)) = 0;
                    graph_schemaball = graph;
                    graph_schemaball = normalize(graph_schemaball,1,'range',[0 1]);
        %             graph = tril(graph);
                    % Rearranging graph for region based clustering
                 if ndim == 48
                    graph2 = graph + graph';
                    graph2 = graph2(re_ROIs_48_index_complete,re_ROIs_48_index_complete);
                    graph2 = tril(graph2);
                    graph_schemaball = normalize(graph2,1,'range',[0 1]);

                    myLabel_2_schemaball = myLabel_2(:,1);

                    %Numbering based labels
                    for LBL = 1:1:24
                        myLabel_2_schemaball{LBL,1} = [num2str(LBL) 'R'];
                    end
                    llb = 24;
                    for LBL = 25:1:48
                        myLabel_2_schemaball{LBL,1} = [num2str(llb) 'L'];
                        llb = llb -1;
                    end

                    C = figure((k*100 + band));
                    set(gcf,'NumberTitle','off') %don't show the figure number
                    set(gcf,'Name',['State ' num2str(k) ' band ' num2str(band)]) %select the name you want
                    schemaball(graph_schemaball,myLabel_2_schemaball,[],colr_mat_2_schm,schemaball_size,colr_mat_2_orig,...
                        ['State ' num2str(k) ' band ' num2str(band)]);
                    clear graph graphmat th grap_ggm

                elseif ndim == 42
                    graph2 = graph + graph';
                    graph2 = graph2(re_ROIs_42_index_complete,re_ROIs_42_index_complete);
                    graph2 = tril(graph2);
                    graph_schemaball = normalize(graph2,1,'range',[0 1]);
                    myLabel_2_schemaball = myLabel_2(4:45,1);
                    if size(colr_mat_2_orig,1)~=42
                        colr_mat_2_orig = colr_mat_2_orig(4:45,:);
                    end
                    if size(colr_mat_2_schm,1)~=42
                        colr_mat_2_schm = colr_mat_2_schm(4:45,:);
                    end

                    psd_scatter_color_rearranged = psd_scatter_color(re_ROIs_42_index_complete,:);
                    %Numbering based labels
        %             for LBL = 1:1:21
        %                 myLabel_2_schemaball{LBL,1} = [num2str(LBL) 'R'];
        %             end
        %             llb = 24;
        %             for LBL = 22:1:42
        %                 myLabel_2_schemaball{LBL,1} = [num2str(llb) 'L'];
        %                 llb = llb -1;
        %             end
                    C = figure((k*100 + band));
                    colr_vals = jet(100);
                    Cc = colr_vals([1,100],:,:);
                    set(gcf,'NumberTitle','off') %don't show the figure number
                    set(gcf,'Name',['State ' num2str(k) ' band ' num2str(band)]) %select the name you want
                    schemaball(graph_schemaball,myLabel_2_schemaball,Cc,colr_mat_2_schm,schemaball_size,colr_mat_2_orig,...
                    ['State ' num2str(k) ' band ' num2str(band)],psd_scatter_color_rearranged, output_path_spectral_figs);
                    
                    % To create glass brain figures for the coherence rings
%                     glassbrain_tactstim
                    clear graph graphmat th grap_ggm
                    close all
                    
                    
                    
                    

                end


          end
        end
end

%% For permutation based testing results
% perm_test = input('Enter yes to plot permutation testing results');
% 
% permutation_results = HMM_permutation_tests.across_tests(1);
% significance_mat = spectsignificance(permutation_results,0.05);
% significance_mat_plot = significance_mat.higher_corr;
% 
% % Dimensions
% K = size(significance_mat_plot.state,2);
% total_band_num = size(significance_mat_plot.state(1).coh,1);
% ndim = size(significance_mat_plot.state(1).coh,2);
% 
% % Color and labels
% colr_mat_2_schm = colr_mat_2_orig;
% schemaball_size = 20*ones(ndim,1);
% [r_schm,c_schm] = find(schemaball_size <= 0);
% myLabel_2_schemaball = myLabel_2(4:45,1);
% if size(colr_mat_2_orig,1)~=42
%     colr_mat_2_orig = colr_mat_2_orig(4:45,:);
% end
% if size(colr_mat_2_schm,1)~=42
%     colr_mat_2_schm = colr_mat_2_schm(4:45,:);
% end
% 
% switch perm_test
%     case 'yes'
%         
%         for k = 1:1:K
%         
%             for band = 1:1:total_band_num 
%                 
%                 graph = double(squeeze(significance_mat_plot.state(k).coh(band,:,:)));
%                 if sum(sum(isany(graph,1)))
%                     graph_schemaball = tril(graph);
%                     C1 = figure(k*1000 + band);
%                     heatmap(graph_schemaball)
%                     C = figure((k*100 + band));
%                     set(gcf,'NumberTitle','off') %don't show the figure number
%                     set(gcf,'Name',['State ' num2str(k) ' band ' num2str(band)])
%                     schemaball(graph_schemaball,myLabel_2_schemaball,[],colr_mat_2_schm,schemaball_size,colr_mat_2_orig,...
%                     ['State ' num2str(k) ' band ' num2str(band)]);
% %                     glassbrain_tactstim
%                 end
%                 
%                 
%             end
%         end
%         
% 
% end
