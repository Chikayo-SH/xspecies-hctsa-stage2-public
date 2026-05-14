function bootstrap_stage1_ab(hctsa_repo, rootDir_override)
% bootstrap_stage1_ab
% Purpose:
%   1) set cosProject/dirPref.rootDir to a writeable rootDir_override
%   2) add required paths (xspecies, chronux, hctsa) in a stable order
%   3) (optional) ensure mex are built (stamp-based)
%   4) (optional) add JIDT/infodynamics jar for Kraskov MI
%
% Inputs:
%   hctsa_repo: path to hctsa repo (A or B)
%   rootDir_override: path to COSproject root (writeable)

%% ---- prefs (cosProject/dirPref) ----
% xspecies provides addDirPrefs_COS.m
addpath("<PROJECT_ROOT>/repos/xspecies_blind_classify","-begin");
addDirPrefs_COS;

dp0 = getpref("cosProject","dirPref"); %#ok<NASGU>
dp = getpref("cosProject","dirPref");
dp.rootDir = char(rootDir_override);
setpref("cosProject","dirPref",dp);

disp("=== PREF dirPref AFTER ===");
disp(getpref("cosProject","dirPref"));

%% ---- paths (fixed order) ----
% Put xspecies + extras early (so helpers are found deterministically)
addpath("<PROJECT_ROOT>/repos/xspecies_blind_classify","-begin");
addpath("<PROJECT_ROOT>/repos/xspecies_blind_classify/Kirill Iowa Intracranial Code","-begin");
addpath("<PROJECT_ROOT>/Toolboxes/xspecies_extra","-begin");

% Optional visualization toolbox (only if exists)
vizDir = "<PROJECT_ROOT>/Toolboxes/xspecies_extra/visualization_unzipped";
if isfolder(vizDir)
    addpath(genpath(vizDir),"-begin");
    disp("Added visualization toolbox: " + string(vizDir));
end

% Chronux 2.11
addpath(genpath("<PROJECT_ROOT>/Toolboxes/chronux/chronux_2_11/chronux_2_11"),"-begin");

% HCTSA repo (A or B)
assert(exist(hctsa_repo,"dir")==7, "hctsa_repo not found: %s", hctsa_repo);
addpath(genpath(hctsa_repo));

% Avoid run.m shadowing (observed conflict with OpenTSTOOL)
badRun = fullfile(hctsa_repo,"Toolboxes","OpenTSTOOL","mex-dev","Lyapunov");
if exist(badRun,"dir")
    rmpath(badRun);
end


%% ---- JIDT / infodynamics jar (Kraskov MI) ----
% Place jar at a fixed path for reproducibility
jidtJar = "<PROJECT_ROOT>/Toolboxes/jidt/infodynamics.jar";
if exist(jidtJar,"file")==2
    javaaddpath(jidtJar);
    disp("JIDT jar added: " + string(jidtJar));
    try
        java.lang.Class.forName("infodynamics.measures.continuous.kraskov.MutualInfoCalculatorMultiVariateKraskov1");
        disp("JIDT class OK: Kraskov1");
    catch ME
        disp("JIDT class NOT available: Kraskov1");
        disp(ME.message);
    end
else
    disp("JIDT jar missing: " + string(jidtJar));
end

%% ---- MEX preflight (stamp-based) ----
disp("=== MEX ===");
disp("mexext=" + string(mexext));

stampDir = fullfile(char(rootDir_override), "_env_stamps");
if ~exist(stampDir,"dir"); mkdir(stampDir); end
stamp = fullfile(stampDir, "mex_built_" + string(version("-release")) + "_" + string(java.lang.String(hctsa_repo).hashCode) + ".txt");

if exist(stamp,"file")==2
    disp("mex_stamp=FOUND (skip compile)");
else
    disp("mex_stamp=NOT FOUND (attempt compile_mex)");
    try
        tb = fullfile(hctsa_repo,"Toolboxes");
        if exist(fullfile(tb,"compile_mex.m"),"file")==2
            cd(tb);
            compile_mex;
            fid=fopen(stamp,"w"); fprintf(fid,"built %s\n", datestr(now)); fclose(fid);
            disp("mex_compile=OK (stamp written)");
        else
            disp("compile_mex.m not found under hctsa_repo/Toolboxes (skip)");
        end
    catch ME
        disp("mex_compile=FAILED");
        disp(getReport(ME,"extended"));
    end
end

%% ---- evidence ----
disp("=== BOOTSTRAP EVIDENCE ===");
disp("matlab=" + string(version) + " release=" + string(version("-release")));
disp("hctsa_repo=" + string(hctsa_repo));

disp(evalc("which -all TS_Init"));
disp(evalc("which -all TS_Compute"));
disp(evalc("which -all BF_NormalizeMatrix"));

disp(evalc("which -all rmlinesc"));
disp(evalc("which -all preprocessOneCh"));
disp(evalc("which -all eventLockedAvg"));
disp(evalc("which -all add_toolbox"));

disp("=== java.class.path contains infodynamics? ===");
cp = string(java.lang.System.getProperty("java.class.path"));
disp(contains(cp, "infodynamics.jar"));


disp("=== javaclasspath (tail) ===");
cp = javaclasspath;
n = min(30, numel(cp));
disp(cp(max(1,numel(cp)-n+1):end));

end
