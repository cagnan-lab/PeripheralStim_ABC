function R = antagonistTestABCAddPaths(R)

switch getenv('computername')
    
    case 'DESKTOP-94CEG1L' % Dell Desktop
        R.path.datapath_shenghong = 'D:\Data\Shenghong_Tremor';
        R.path.datapath_pedrosa_ThalMusc = 'D:\Data\DP_Tremor_ThalamoMuscular\';
    case 'DESKTOP-1QJTIMO' % Dell Laptop
        R.path.datapath_shenghong = 'C:\DATA\Shenghong_Tremor';
        R.path.datapath_pedrosa_ThalMusc = 'C:\DATA\DP_Tremor_ThalamoMuscular\';
end
end

