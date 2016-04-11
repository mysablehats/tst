function [SLASH, pathtodata] = OS_VARS()
if ispc
    SLASH = '\'; % windows 
    pathtodata = 'E:\fall_detection_datasets\TST Fall detection database ver. 2\';
elseif ismac
    pathtodata = '/remote/elements/fall_detection_datasets/TST Fall detection database ver. 2/';
    SLASH = '/'; %                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
elseif isunix
    %pathtodata = '/media/Elements/fall_detection_datasets/TST Fall detection database ver. 2/';
    pathtodata = '/media/fbklein/share/fall_detection_datasets/TST Fall detection database ver. 2/';
    SLASH = '/'; % 
else
    error('Cant determine OS')
end