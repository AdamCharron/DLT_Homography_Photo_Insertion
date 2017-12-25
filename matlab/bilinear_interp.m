function [b] = bilinear_interp(I, pt)
% bilinear_interp Performs bilinear interpolation for a given image point.
%
%   Given the (x y) location of a point in an input image, use the 
%   surrouning 4 pixels to output the bilinearly interpolated intensity.
%
%  Inputs:
%  -------
%   I   - Input image (monochrome, one channel - n rows x m columns).
%   pt  - Point in input image (x, y), with subpixel precision.
%
%  Outputs
%  -------
%   b  - Interpolated brightness or intensity value (whole number >= 0).

    x = pt(2);
    y = pt(1);

    x1 = -1;
    x2 = -1;
    y1 = -1;
    y2 = -1;

    if floor(x) == ceil(x) && floor(y) == ceil(y)
        % If x and y are integers, we can get the value by indexing the image
        b = I(x,y);
    else
        dim_I = size(I);

        % Deal with X corner cases
        if (ceil(x) >= dim_I(1))
            if (ceil(x) > dim_I(1))
                x2 = floor(x);
            else
                x2 = ceil(x);
            end
            x1 = x2-1;
        else
            x1 = floor(x);
            x2 = x1 + 1;
        end

        % Deal with Y corner cases
        if (ceil(y) >= dim_I(2))
            if (ceil(y) > dim_I(2))
                y2 = floor(y);
            else
                y2 = ceil(y);
            end
            y1 = y2-1;
        else
            y1 = floor(y);
            y2 = y1 + 1;
        end

        % Calculate bilinear interpolation of the point based on surrounding points
        I = double(I);
        b = uint8((1/((x2-x1)*(y2-y1)))*[x2-x, x-x1]*[I(x1,y1), I(x1,y2); I(x2,y1), I(x2,y2)]*[y2-y; y-y1]);

    end

end
