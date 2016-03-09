%longinputtest_script.m

shortinput = reshape(1:44,4,11);

q = 3;

ends = [6, 5];

newends_should = [4, 3];

linput_size = [12,7];

[linput,newends] = longinput(shortinput, q, ends)

if size(linput)==linput_size
    disp('the size is fine!')
else
    disp('the size is wrong!!!!')
end
if all(newends==newends_should)
    disp('also the ends are right')
else
    disp('problems with ends :(')
end