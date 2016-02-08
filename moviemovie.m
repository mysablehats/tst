%showmovie, this is the movie of the last thing the database loaded, in
%this case fall endupsit 3

function moviemovie(Data,j)
hold on
n = 10;
skeldraw(Data(:,j))
%nada = input('adjust the axis','s');
%lim = axis;
%axis manual
for i=0:n
    skeldraw(Data(:,j+i))
    %axis(lim)
    %F(i+1) = getframe;
end
hold off
%movie(F,20)