global wheretosavestuff SLASH
if isempty(wheretosavestuff)||isempty(SLASH)
    aa_environment
end
load(strcat(wheretosavestuff,SLASH,'test_skel.mat'));