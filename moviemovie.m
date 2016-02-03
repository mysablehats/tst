%showmovie, this is the movie of the last thing the database loaded, in
%this case fall endupsit 3
%hold on
plot3(jMatDep(:,1,1),jMatDep(:,3,1),jMatDep(:,2,1),'.b','markersize',20); view(0,0); axis equal; set(gca,'ZDir','Reverse');
lim = axis;
axis manual

for i=1:n
    plot3(jMatDep(:,1,i),jMatDep(:,3,i),jMatDep(:,2,i),'.b','markersize',20); view(0,0); set(gca,'ZDir','Reverse');
    axis(lim)
    %axes(lim)
    F(i) = getframe;
end
%hold off
movie(F,20)