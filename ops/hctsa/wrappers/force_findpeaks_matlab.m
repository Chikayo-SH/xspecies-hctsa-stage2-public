function force_findpeaks_matlab()
fp_all = which('findpeaks','-all');
for i = 1:numel(fp_all)
    p = fp_all{i};
    if contains(p, 'chronux') && endsWith(p, [filesep 'findpeaks.m'])
        rmpath(fileparts(p));
    end
end
rehash path;
fp_after = which('findpeaks','-all');
disp('which_findpeaks_after_force=');
if ~isempty(fp_after), disp(fp_after{1}); end
end
