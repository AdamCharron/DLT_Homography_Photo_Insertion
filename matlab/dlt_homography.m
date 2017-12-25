function [H, A] = dlt_homography(I1pts, I2pts)
% dlt_homography Perspective Homography between two images.
%
%   Given 4 points from 2 separate images, compute the perspective homograpy
%   (warp) between these points using the DLT algorithm.
%
%   Inputs:
%   -------
%    I1pts  - 2x4 array of points from Image 1 (each column is x, y).
%    I2pts  - 2x4 array of points from Image 2 (1-to-1 correspondence).
%
%   Outputs:
%   --------
%    H  - 3x3 perspective homography (matrix map) between image coordinates.
%    A  - 8x9 DLT matrix used to determine homography.
    
    pts1 = I1pts;
    pts2 = I2pts;

    initial_centroid1 = [sum(pts1(1,:))/4, sum(pts1(2,:))/4];
    initial_centroid2 = [sum(pts2(1,:))/4, sum(pts2(2,:))/4];
    
    % d = average distance from the origin
    d1 = 0;
    d2 = 0;
    for i=1:4 
       x1 = pts1(1,i);
       y1 = pts1(2,i);
       x2 = pts2(1,i);
       y2 = pts2(2,i);
       d1 = d1 + sqrt((x1-initial_centroid1(1))^2 + (y1-initial_centroid1(2))^2);
       d2 = d2 + sqrt((x2-initial_centroid2(1))^2 + (y2-initial_centroid2(2))^2);
    end
    
    d1 = d1/4;
    d2 = d2/4;
    
    % Compute scaling factor for points
    scaling_factor1 = d1/sqrt(2);
    scaling_factor2 = d2/sqrt(2);

    % Compute T for each of the 2 sets of points
    T1 = [ 1/scaling_factor1, 0, -initial_centroid1(1)/scaling_factor1; ...
          0, 1/scaling_factor1, -initial_centroid1(2)/scaling_factor1; ...
          0, 0, 1];
    T2 = [ 1/scaling_factor2, 0, -initial_centroid2(1)/scaling_factor2; ...
          0, 1/scaling_factor2, -initial_centroid2(2)/scaling_factor2; ...
          0, 0, 1];
    
    % Compute the transformed x values for each of the 2 sets of points
    temp_pts1 = cat(1,pts1,ones(1,4));
    temp_pts2 = cat(1,pts2,ones(1,4));
    x1_prime = T1*temp_pts1;
    x2_prime = T2*temp_pts2;
    x1_prime = x1_prime(1:2,:);
    x2_prime = x2_prime(1:2,:);

    % Create A matrix based on the equation covered in the homography paper
    A = zeros(8,9);
    for i=1:4
        x = x1_prime(1,i);
        y = x1_prime(2,i);
        u = x2_prime(1,i);
        v = x2_prime(2,i);
        A(2*i-1,:) = [-x, -y, -1, 0, 0, 0, u*x, u*y, u];
        A(2*i,:) = [0, 0, 0, -x, -y, -1, v*x, v*y, v];
    end
    
    % Compute h as the nullspace of A (Ah=0), and put it in matrix form
    h = null(A);
    H = [h(1), h(2), h(3);h(4), h(5), h(6);h(7), h(8), h(9)];

    % Normalize
    H = inv(T2)*H*T1;
  
end