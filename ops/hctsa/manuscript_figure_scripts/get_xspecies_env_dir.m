function dirPath = get_xspecies_env_dir(envName, fallbackRelativePath)
%GET_XSPECIES_ENV_DIR Return a data directory specified by an environment variable.
%
% If the environment variable is not set, this function falls back to a
% repository-relative path. Data files are not included in this repository,
% so users will usually need to set the relevant environment variable.

dirPath = getenv(char(envName));

if isempty(dirPath)
    here = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(fileparts(fileparts(here)));
    dirPath = fullfile(repoRoot, fallbackRelativePath);
end

if ~isfolder(dirPath)
    warning('Data directory does not exist: %s', dirPath);
end
end
