function [] = comparison()
    clc ;
    clear all ;
    close all ;

    % load the sample image
    sample_path = '.\sample\' ;
    sample_file_list = dir(strcat(sample_path, '*.jpg')) ;
    sample_amount = length(sample_file_list) ;
    if sample_amount > 0
        sample = double(imread(strcat(sample_path, sample_file_list(1).name))) ;
    end
    image_size = size(sample) ;

    % load images for comparison
    image_path = '.\images\' ;
    image_file_list = dir(strcat(image_path, '*.jpg')) ;
    image_amount = length(image_file_list)  ;

    mark_path = '.\mark\';
    if image_amount > 0
        for ii = 1:image_amount
            % read image
            try
                img = double(imread(strcat(image_path, image_file_list(ii).name))) ;
            catch
               continue ; 
            end

            % compare
            difference = abs(img-sample) ;
            mask = (( difference(:,:,1) | difference(:,:,2) | difference(:,:,3) ) ~= 0) ;

            % re-construct mask
            region_size = 10 ;
            region_mask = ones(region_size) ;
            for jj = 1:image_size(1)/region_size
                for kk = 1:image_size(2)/region_size
                    nonzero = sum(sum(region_mask .* mask((1+(jj-1)*region_size):jj*region_size, (1+(kk-1)*region_size):kk*region_size))) ;
                    if nonzero~=0
                        for mm = 1:region_size
                            for nn = 1:region_size
                                mask((jj-1)*region_size+mm, (kk-1)*region_size+nn) = 255 ;
                            end
                        end
                    end
                end
            end
            mask = bwlabel(mask, 4) ;

            tmp = mask ;
            marker_width = 5 ;
            for jj = (marker_width+1):(size(mask, 1)-marker_width)
                for kk = (marker_width+1):(size(mask, 2)-marker_width)
                    if mask(jj, kk) ~= 0
                        red_mask = ones(2*marker_width+1) * mask(jj, kk) ;
                        %count = 0 ;
                        count = sum(abs(bitxor(red_mask,mask((jj-marker_width):(jj+marker_width),(kk-marker_width):(kk+marker_width)))));
                        if count == 0
                            tmp(jj, kk) = 0 ;
                        end
                    end
                end
            end
            mask = tmp ;

            % label red line
            for jj = 1:image_size(1)
                for kk = 1:image_size(2)
                    if mask(jj, kk) ~= 0
                        img(jj, kk, 1) = 255 ;
                        img(jj, kk, 2) = 0 ;
                        img(jj, kk, 3) = 0 ;
                    end
                end
            end

            img = uint8(img) ;
            imwrite(img, strcat(strcat(mark_path,'mark_'), image_file_list(ii).name)) ;
        end
    end
end