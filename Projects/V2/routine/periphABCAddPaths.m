function R = periphABCAddPaths(R)

switch getenv('computername')
    case 'DESKTOP-0HO6J14'
        R.path.datapath_shenghong = 'D:\Data\Shenghong_Tremor';
        R.path.datapath_pedrosa_ThalMusc = 'D:\Data\DP_Tremor_ThalamoMuscular\';
    spmpath = 'D:\GITHUB\spm12';

    case 'DESKTOP-94CEG1L'
        R.path.datapath_shenghong = 'D:\Data\Shenghong_Tremor';
        R.path.datapath_pedrosa_ThalMusc = 'D:\Data\DP_Tremor_ThalamoMuscular\';
    case 'DESKTOP-4VATHIO'
        R.path.datapath_shenghong = 'D:\DATA\Shenghong_Tremor';
        R.path.datapath_pedrosa_ThalMusc = 'D:\DATA\DP_Tremor_ThalamoMuscular\';
    spmpath = 'C:\Users\timot\Documents\GitHub\spm12';
    case 'OPAL'
        R.path.datapath_shenghong = 'D:\DATA\Shenghong_Tremor';
        R.path.datapath_pedrosa_ThalMusc = 'D:\DATA\DP_Tremor_ThalamoMuscular\';
    spmpath = 'C:\Users\ndcn0903\Documents\GitHub\spm12';
    
end

