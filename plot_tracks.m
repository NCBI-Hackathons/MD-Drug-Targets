%% Get the lengths of each track
nTracks = numel(tracksFinal);
trackLengths = [];
tracks = {};
events= [];
for t = 1:nTracks
   track = tracksFinal(t).tracksCoordAmpCG;
   nSubTracks = size(track, 1);
   for s = 1:nSubTracks
       trackLength = sum(track(s, :) > 0) / 4;
       trackLengths = [trackLengths; trackLength];
       tracks = [tracks; track(s, :)];
       
   end
   events = [events; tracksFinal(t).seqOfEvents];
end
[longest, idx ] =sort(trackLengths, 'descend');

%% plot volume vs. time of the 5 longest lasting pockets
for i = 1:5
    longestTrack = idx(i);
    traj = tracks{longestTrack};
    trackVol = traj(4:4:end);
    trackX = traj(1:4:end);
    trackY = traj(2:4:end);
    trackZ = traj(3:4:end);
    [maxVol, maxVolIdx ] = max(trackVol);
    centroidMax = [trackX(maxVolIdx), trackY(maxVolIdx), trackZ(maxVolIdx)];

    figure; plot(10*[1:numel(trackVol)], trackVol)
    xlabel('Time (ns)')
end
ylabel('Pocket volume (cubic Angstroms)')