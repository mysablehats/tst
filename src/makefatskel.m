function [tdskel,hh] = makefatskel(skel)
%%%%%%%%%MESSAGES PART
%%%%%%%%ATTENTION: this function is executed within loops, so running it will
%%%%%%%%messages on will cause unpredictable behaviour
%dbgmsg('Removing displacement based on hip coordinates (1st point on 25x3 skeleton matrix) from every other')
%dbgmsg('This makes the dataset translation invariant')
%%%%%%%%%%%%%%%%%%%%%
howmanyskels = size(skel,2);
if howmanyskels>1
    [tdskel,hh] = makefatskel(skel(:,1));
    for i = 2:howmanyskels
        [currskel, ~] = makefatskel(skel(:,i));
        tdskel = cat(3, tdskel, currskel );
        %hh = cat(2, hh, currhh); %% hh will not change, it is matrix,
        %come on...
    end
else
    
    hh = size(skel,1)/3;
    %%%% reshape skeleton
    if all(size(skel) == [75 1]) % checks if the skeleton is a 75x1
        tdskel = zeros(25,3);
        for i=1:3
            for j=1:25
                tdskel(j,i) = skel(j+25*(i-1));
            end
        end
    elseif all(size(skel) == [150 1])
        tdskel = reshape(skel,hh,3); %%%%%I think this should work for every skeleton Nx3, but I will not change the function that came before, because (at least I think), it is working
    elseif all(size(skel) == [25 3])
        tdskel = skel;
    else
        %disp('Not sure, but will try just the reshape...')
        try
            tdskel = reshape(skel,hh,3);
        catch
            disp('Yup, reshaping didnt work...')
        end
    end
end
end
