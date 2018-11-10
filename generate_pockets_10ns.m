dataDir = '/project/hackathon/hackers04/shared/frames';
files = dir(fullfile(dataDir, 'frame*.mat'));
nFiles = length(files);

for i = 1:nFiles
    if mod(nFiles, 100) == 0
        fprintf('Frame %d\n', i)
    end
    vFile = strcat('frame_', int2str(i), '.mat');
    V = load(fullfile(dataDir, vFile));
    V = struct2cell(V);
    V = V{1};
    minRadius = 5;
    maxRadius = 10;
%     tic
    [pocketMap, pockets, components] = find_pockets(V > 0, minRadius, maxRadius);
%     toc
    filename = sprintf('/project/hackathon/hackers04/shared/pocket-maps/frame_%06d.mat', i);
    save(filename, 'V', 'pocketMap', 'pockets', 'components')
end