function [sliced_array] = slice_array(full_array,slice)
%SLICE_ARRAY Just to consistently slice arrays into upper, mid and lower
%sections.
    if strcmpi(slice,'upper')
        sliced_array = full_array((end-15):end);
    end

    if strcmpi(slice,'lower')
        sliced_array = full_array(1:(16));
    end

    if strcmpi(slice,'mid')
        sliced_array = full_array(3:18);
    end
end

