%  Use DLT homography and bilinear interpolation functions to
%  produce a 'hacked' billboard, automatically stitching U of T's soldier 
%  tower into a Yonge and Dundas billboard

clear all
clc

file_path = '../billboard/';
billboard_image = 'yonge_dundas_square.jpg';
tower_image = 'uoft_soldiers_tower.jpg';

billboard_full_name = strcat(file_path, billboard_image);
tower_full_name = strcat(file_path, tower_image);

% Open images for tower and billboard
billboard_im = imread(billboard_full_name);
tower_im = imread(tower_full_name);

% Top-left, bottom-left, top-right, bottom-right
% Coords are [col, row] = (x,y)
bounds_tower = [1,1; 1,412; 221,1 ; 221,412]';
bounds_billboard = [416,40; 414,347; 485,61; 486,351]';

% Get Homography matrix, A matrix, and inverse Homography matrix
[H, A] = dlt_homography(bounds_tower, bounds_billboard);
H_inv = inv(H);

% Save time by determining an array of binary values to see if pixels in
% billboard image are actually in the billboard
maxL = max(bounds_billboard(1,:));
minL = min(bounds_billboard(1,:));
maxH = max(bounds_billboard(2,:));
minH = min(bounds_billboard(2,:));
max_tower_L = max(bounds_tower(1,:));
max_tower_H = max(bounds_tower(2,:));
min_tower_L = min(bounds_tower(1,:));
min_tower_H = min(bounds_tower(2,:));
for i=minL:maxL
    for j=minH:maxH
        % Go through the entire rectangle covering the billboard + other
        % space. For each coordinate, reverse transform it back to the
        % coordinates of the tower. If it is on the power image, it is
        % valid, and we can use bilinear interpolation to get its value.
        % Otherwise, it is not prcisely on the billboard, so leave it
        tower_coords = H_inv*[i,j,1]';
        tower_coords = [tower_coords(1)/tower_coords(3); tower_coords(2)/tower_coords(3)];
        if (((tower_coords(1) < max_tower_L) && (tower_coords(1) > min_tower_L)) ...
                && ((tower_coords(2) < max_tower_H) && (tower_coords(2) > min_tower_H)))
            % Repeat bilinear interpolation 3 times for RGB pixels
            billboard_im(j,i,1) = bilinear_interp(tower_im(:,:,1), [tower_coords(1), tower_coords(2)]);
            billboard_im(j,i,2) = bilinear_interp(tower_im(:,:,2), [tower_coords(1), tower_coords(2)]);
            billboard_im(j,i,3) = bilinear_interp(tower_im(:,:,3), [tower_coords(1), tower_coords(2)]);
        end
    end
end

% Save the image to a file, display it
hacked_image = 'billboard.png';
imwrite(billboard_im, hacked_image);
imshow(billboard_im);
%------------------
