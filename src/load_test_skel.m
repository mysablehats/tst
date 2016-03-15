global pathtodropbox SLASH
if isempty(pathtodropbox)||isempty(SLASH)
    aa_environment
end
load(strcat(pathtodropbox,SLASH,'share',SLASH,'test_skel.mat'));