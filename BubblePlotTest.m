x=[0 2.5 -1];
y=[-1 0 1];
z=[1 -1 0];
r=[.3 .6 .9];
bubbleplot3(x,y,z,r,[],[],[],[],'Tag','MyFirstBubbleplot3Bubbles')
shading interp; camlight right; lighting phong; view(60,30);