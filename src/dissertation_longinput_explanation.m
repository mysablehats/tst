%% The Hierarchical Learning and Integration
% In this section I try to explain how the skeleton data is concatenated
% and fed as input for the gases as well as a good description of the tests
% implemented to check if it was giving the right results.

%%
% Instead of actual skeleton data I will build a matrix of sequential
% points so that the reshaping becomes more evident. For my work, each
% skeleton is a column vector and the whole dataset is composed of
% skeletons put together side by side, i.e. horizontally concatenated.
% First let's build a matrix that has this distribution, but with only 4
% lines as oposed to the 25 we have. We can do it as such:
shortinput = reshape(1:4*11,4,[])

%%
% We also need to create the y variable for the longinput function to clip,
% as the size also changes when do do this concatenation. Actually y is the
% same for all the action, so there would perhaps be a better way of
% constructing this if we kept the data structure of multiple actions, but
% I will do it like this. I will generate a sequence, so that we know where
% we are cliping it

y = 1:size(shortinput,2)

%%
% The idea behind constructing longer inputs is that we can have some
% information linking the temporal changes in our data. The way this was implemented was with the usage of a sliding window scheme. It is basically the concatenation over time of q samples, in a way that is you have a vector of dimensionality k, the end vector has the dimensionality k*q. Now let us assume
% that we are puting together a vector of q = 3 with our input of k = 4 from
% the matrix we just generated.

q = 3;

%%
% Some other necessary step is to have a vector with the ends of each
% action. This is necessary because our dataset is made from the
% concatenation of different action sequences and the sliding window from
% one action to the other has no meaning whatsoever. 
% Note that these values will change, as the time sliding window concatenated vectors will not have the same length as the original dataset.  

ends = [6, 5];

%%
% From constructing the vector manually for our example, I know that the
% vector should have the ands like this:

newends_should = [4, 3];

%%
% Actually it is easy to see that each action will make the dataset shorter
% by q - 1 samples, so in our case, first action ends at 6, so the new end
% will be: end - (q-1), with q = 3 and ends = [6, 5]
6 - (3 - 1)

5 - (3 - 1)

%%
% The automated test procedure for any ends array can be thus defined as:

newends_should_auto = ends - ( q - 1)

%% 
% Another check is to see if the size of the resulting array is correct. We
% know from constructing the array by hand that it would have the following
% dimensions:
linput_size = [12,7];

%%
% The generalization is an input with k*q lines and a size diminished by
% num_of_actions*(q-1) or in matlab

[k datasetlength ]= size(shortinput)
linput_size_auto = [k*q, datasetlength - size(ends,2)*(q-1) ]

%%
% The actual function then:

[linput,newends, newy] = longinput(shortinput, q, ends,y)

%%
% We can see it gives us our expected result, but it is better to run the
% checks:

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

%% 
% We can try now with a bigger set, say:

k = 10
q = 3

ends = fix(rand(1,10)*10) + q % the +q here means I always have at least enough data to fill one long-vector; the shorter action samples would just be discarded. The algorithm does this, but checking it automatically would be a little more complicated.

sum(ends); % this should be equal to the size of the dataset

shortinput = reshape(1:k*sum(ends),k,[])

y = 1:size(shortinput,2) %ones(1, size(shortinput,2)) % also need to redefine y

%%
newends_should_auto = ends - ( q - 1) % will output, but mostly I want to check automatically with the if clauses
[k datasetlength ]= size(shortinput)
linput_size_auto = [k*q, datasetlength - size(ends,2)*(q-1) ]
%%
[linput,newends, newy] = longinput(shortinput, q, ends,y) % will output; but it is too big for visual inspection

%%
% Finally checking what we did:
if all(size(linput)==linput_size_auto)
    disp('the size is fine!')
else
    disp('the size is wrong!!!!')
end
if all(newends==newends_should_auto)
    disp('also the ends are right')
else
    disp('problems with ends :(')
end

%% But this is not exactly what Parisi did...
% Our naive approach to implement the sliding window
