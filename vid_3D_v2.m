files = dir('/project/hackathon/hackers04/shared/pocket-maps/*.mat');
N = length(files);


filename = 'animation_n100.gif'
first_frame = true;

for i = 1:N
    dataDir = '/project/hackathon/hackers04/shared/pocket-maps';
    vFile = files(i).name;
    load(fullfile(dataDir, vFile))
    hold off;
    
    % Clear old rendering
    if i > 1
        delete(h)
        for m = 1:numel(mesh)
            delete(mesh{m});
        end
    end
    meshProtein = isosurface(V, 0);
    center = mean(meshProtein.vertices, 1);
    meshProtein.vertices = meshProtein.vertices - center;
    h = patch(meshProtein, 'FaceColor', [.9 .9 .9], 'FaceAlpha', 1, 'EdgeColor', 'none');
    title(sprintf('Frame %06d', i))
    hold on;
    mesh = {};
    for p = 1:numel(pockets)
        meshPocket = isosurface(pocketMap == pockets(p).Area, 0.5, pocketMap);
        meshPocket.vertices = meshPocket.vertices - center;
        mesh{p} = patch(meshPocket, 'FaceColor', ...
            'interp', 'EdgeColor', 'none', 'FaceAlpha', .5);
        set(mesh{p},'ambientstrength',0.35);
    end
    if i == 1
        
        axis on
        view([-100,10]);
        camlight()

    end
        caxis([0, 500]);
        clim = colorbar();
    lighting phong
    drawnow    
    
    %gif
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if first_frame
        imwrite(imind,cm,filename,'gif','DelayTime',0.2,'Loopcount',inf);
        first_frame = false;
    else
        imwrite(imind,cm,filename,'gif','DelayTime',0.2,'WriteMode','append');
    end
    
    
    %save_3D_matrix_as_gif('C:/project/hackathon/hackers04/shared/3D vid',mesh,0.0001)
end

