import Simplex

close all
clear
clc


global M
global Q
global q


Q = [-.4 -.4 -.4
    0 -.2 -.3
    .4 0 .3
    .3 .3 .3
    -.2 .3 -.2
    .2 -.2 -.1
    -.2 .1 0
    -.3 .4 .4
    .3 .4 .3
    -.3 .4 -.2]; %10 charges
q = Q(end, :); %the unknown charge
Q = Q(1:end-1, :); %the other 9 known charges
M = [];

%mapping the measurers box
for i = -1:1:1
    for j = -1:1:1
        %X planes
        M = [M; [-1, i, j]];
        M = [M; [1, i, j]];

        %Y planes
        M = [M; [i, -1, j]];
        M = [M; [i, 1, j]];

        %Z planes
        M = [M; [i, j, -1]];
        M = [M; [i, j, 1]];
    end
end

%initializing Simplex class
s = Simplex(@cost_function, {}, [-.3 -.3 .1], .075, 1e-5, 25); % NOTE: I have changed the value
s.dt = 0; %animation delta time between frames (0 = off)
s.field = .7; %figure subspace of view
s.slices = 20; %10 planes to draw the isolevel maps
s.plot = true; %enable the polotting

[value, coordinates, flips, halvings, area] =  s.compute() %compute the algorithm


disp('known charge');
disp(q);

error_v = abs(cost_function(coordinates) - cost_function(q));
error_c = abs(coordinates - q);
disp('error');
disp(error_v)
disp(error_c)

function f = bound1(x, y, z) %sp here bound
    f = -((x+1.5).^2 + (y+1.5).^2 + (z-.8).^2 - 2^2);
end

function f = bound2(x, y, z) %sphere bound
    f = -((x+1.5).^2 + (y+1.5).^2 + (z+.5).^2 - 2^2);
end

function E = cost_function(qu)
    global M 
    global Q 
    global q
    
    U = get_all_potentials([Q; q]); %get the whole potentials measured from the measurers
    Un = get_all_potentials([Q; qu]); %get the known charges potentials
    Uc = U - Un; %clean the measure to get only the potential of the unknown charge
    %In this way we'll have only the difference from the unknown charge's
    %potential and the generic charge computed in the qu position
    %We don't use the absolute value because in a further step we'll
    %exponentiate by 2 all the values
    
    E = sum(Uc.^2); %sum quadratically the single cost functions to minimize them all
end

function U = get_all_potentials(Q)
    global M
    
    U = [];
    for i = 1:length(M(:, 1)) %for each measurer
        Um = 0;
        for j = 1:length(Q(:, 1)) %for each charge
            Um = Um + get_potential(Q(j, :), M(i, :)); %sum the potential of the j-th charge
        end
        
        U = [U Um]; %store the measurer detection
    end
end

function u = get_potential(p, m) %compute charge's potential detected from a measurer
    u = 1/(norm(p-m)*sqrt(12)); %yet normalized % NOTE: Non dobbiamo normalizzare anche su M?  
    
end