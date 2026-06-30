function out = run_reproduce_suppfig1_epoch6s()
% Recommended entrypoint for reproducing Supplementary Figure 1-like 6-s figure.
% Run from MATLAB:
%   run_reproduce_suppfig1_epoch6s

    here = fileparts(mfilename("fullpath"));
    addpath(here);

    out = replot_suppfig1_epoch6s_from_local_data();

    fprintf("Done. Output directory:\n%s\n", out.outDir);
end
