function o = find_spots2(o)          %ADDING t2 BIT BACK IN
% o = o.find_spots2;
%
% finds spots in all tiles using the reference channel, removes
% duplicates in overlap regions and returns nSpots x 2 array o.SpotGlobalYX of
% coordinates in global frame
% 
% Looks up colors from apporpriate files and makes nSpots x nBP x nRounds
% array o.SpotColors
%
% o.Isolated is a nSpots x 1 binary array giving 1 for
% well-isolated spots
%
% NB spots that can't be read in all rounds are discarded
% 
% This finds initial shifts between rounds using point cloud not by finding 
% the max correlation between images
%
% Kenneth D. Harris, 29/3/17
% GPL 3.0 https://www.gnu.org/licenses/gpl-3.0.en.html

%% variable naming conventions:
% spot subgroups:
% All: Any spot included in any tile (includes duplicates)
% nd: only spots whose anchor coordinate is in its home tile (no duplicates)
% Good: Spots for which could be read for all rounds

% coordinate frames or other info
% LocalYX: relative to home tile on the reference round
% LocalTile: number of home tile on the reference round
% GlobalYX: relative to the stitched image on the reference round
% RoundYX: relative to home tile after registration on each round
% RoundTile: number of home tile after registration on each round
% Isolated: binary number, saying if it is isolated
% SpotColors: the answer:

%% basic variables
rr = o.ReferenceRound;
Tiles = find(~o.EmptyTiles)';

[nY, nX] = size(o.EmptyTiles);
nTiles = nY*nX;

    
%% now make array of global coordinates
AllIsolated = logical(vertcat(o.RawIsolated{:})); % I HATE MATLAB - for converting logical to doubles for no reason
AllAnchorChannel = int16(vertcat(o.RawChannel{:}));
nAll = length(AllIsolated);

AllGlobalYXZ = zeros(nAll,3);
AllLocalYXZ = zeros(nAll,3);
OriginalTile = zeros(nAll,1);

ind = 1;
for t=Tiles
    MySpots = o.RawLocalYXZ{t};
    nMySpots = size(MySpots, 1);
    AllGlobalYXZ(ind:ind+nMySpots-1,:) = bsxfun(@plus, MySpots, o.TileOrigin(t,:,rr));
    AllLocalYXZ(ind:ind+nMySpots-1,:) = MySpots;
    OriginalTile(ind:ind+nMySpots-1) = t;
    ind = ind+nMySpots;
end
if o.Graphics
    plotAnchorSpotsGlobal(AllGlobalYXZ,'All global coords including duplicates')
end

%% now remove duplicates by keeping only spots detected on their home tile

[AllLocalTile, ~] = which_tile(AllGlobalYXZ, o.TileOrigin(:,:,rr), o.TileSz);
NotDuplicate = (AllLocalTile==OriginalTile);
ndGlobalYXZ = AllGlobalYXZ(NotDuplicate,:);
ndLocalYXZ = AllLocalYXZ(NotDuplicate,:);
ndIsolated = AllIsolated(NotDuplicate,:);
ndLocalTile = AllLocalTile(NotDuplicate,:);
ndAnchorChannel = AllAnchorChannel(NotDuplicate,:);

nnd = sum(NotDuplicate);

if o.Graphics
    plotAnchorSpotsGlobal(ndGlobalYXZ,'Global coords without duplicates')
end


%% get spot local coordinates in all colour channels
AllBaseLocalYXZ = cell(nTiles,o.nBP, o.nRounds);


%Specify which rounds/colour channels to use (default is all)
if isempty(o.UseChannels)
    o.UseChannels = 1:o.nBP;
end

if isempty(o.UseRounds)
    o.UseRounds = 1:o.nRounds;
end

% loop through all tiles, finding PCR outputs
fprintf('\nLocating spots in each colour channel of tile   ');

%For scaling need to be centered about 0 hence subtract this
o.CentreCorrection = [1+(o.TileSz-1)/2,1+(o.TileSz-1)/2,1+(o.nZ-1)/2];

for t=1:nTiles
    if o.EmptyTiles(t); continue; end
    
    if t<10
        fprintf('\b%d',t);
    else
        fprintf('\b\b%d',t);
    end 
    
    [y, x] = ind2sub([nY nX], t);

    for r = o.UseRounds
        % find spots whose home tile on round r is t      
        % open file for this tile/round       
        % now read in images for each base
        
        for b = o.UseChannels              
            %if b == 5 || b ==6 %Only for specific case
            %    o.DetectionThresh = 500;
            %else
            %    o.DetectionThresh = 900;
            %end
            BaseIm = o.load_3D(r,y,x,o.FirstBaseChannel + b - 1)-o.TilePixelValueShift;
            %BaseIm = imfilter(BaseIm, SE);
            %o.MinThresh = max(mean(mean(BaseIm)));
            %o.DetectionThresh = 1.5*max(mean(mean(BaseIm)));
            % find spots for base b on tile t - we will use this for point
            % cloud registration only, we don't use these detections to
            % detect colors, we read the colors off the
            % pointcloud-corrected positions of the spots detected in the reference round home tiles  
            CenteredSpots = o.detect_spots(BaseIm,t,b,r) - o.CentreCorrection;
            %Scale so all in terms of XY pixel size. Import for PCR as find
            %nearest neighbours
            AllBaseLocalYXZ(t,b,r) = {CenteredSpots.*[1,1,o.Zpixelsize/o.XYpixelsize]};
        end        
    end      
end
fprintf('\n');

%Save workspace at various stages so dont have to go back to the beginning
%and often fails at PCR step.
save(fullfile(o.OutputDirectory, 'FindSpotsWorkspace.mat'), 'o', 'AllBaseLocalYXZ');

%% Find initial shifts between rounds and then run PCR
%Should have a initial search range for each round. If only provided one,
%set all other rounds to the same range.
if size(o.FindSpotsSearch,1) == 1
    FindSpotsSearch = cell(o.nRounds,1);
    for r = o.UseRounds
        FindSpotsSearch{r} = o.FindSpotsSearch;
    end
    o.FindSpotsSearch = FindSpotsSearch;
    clear FindSpotsSearch
end

%Unless specified, set initial shift channel to be the one with largest
%number of spots on tile/round with least spots.
AllBaseSpotNo = cell2mat(cellfun(@size,AllBaseLocalYXZ,'uni',false));
o.AllBaseSpotNo = AllBaseSpotNo(:,1:2:o.nRounds*2,:);
MinColorChannelSpotNo = min(min(o.AllBaseSpotNo(Tiles,:,:)),[],3);
if ~ismember(string(o.InitialShiftChannel),string(o.UseRounds))
    [~,o.InitialShiftChannel] = max(MinColorChannelSpotNo);
end

if MinColorChannelSpotNo(o.InitialShiftChannel)< o.MinSpots
    [BestSpots,BestChannel] = max(MinColorChannelSpotNo);
    if BestSpots >= o.MinSpots
        warning('Changing from Color Channel (%d) to Color Channel (%d) to find initial shifts.',o.InitialShiftChannel,BestChannel);
        o.InitialShiftChannel = BestChannel;
    else
        error('Best Color Channel (%d) only has %d spots. Not enough for finding initial shifts. Consider reducing o.DetectionThresh.'...
            ,BestChannel,BestSpots);
    end
end

o.D0 = zeros(nTiles,3,o.nRounds);
Scores = zeros(nTiles,o.nRounds);
ChangedSearch = zeros(o.nRounds,1);
OutlierShifts = zeros(nTiles,3,o.nRounds);

for t=1:nTiles
    if o.EmptyTiles(t); continue; end
    for r = o.UseRounds
        tic
        [o.D0(t,:,r), Scores(t,r),tChangedSearch] = o.get_initial_shift2(AllBaseLocalYXZ{t,o.InitialShiftChannel,r},...
            o.RawLocalYXZ{t}, o.FindSpotsSearch{r},'FindSpots');
        toc
        ChangedSearch(r) = ChangedSearch(r)+tChangedSearch;
        
        fprintf('Tile %d, shift from anchor round to round %d: [%d %d %d], score %f\n', t, r, o.D0(t,:,r),...
            Scores(t,r));
        
        %Change search range after 3 tiles or if search has had to be widened twice (This is for speed).
        if t == 3 || (mod(ChangedSearch(r),2) == 0) && (ChangedSearch(r)>0)
            o = o.GetNewSearchRange_FindSpots(t,r);
        end
        
    end
end

for r = o.UseRounds
    [o.D0(:,:,r), OutlierShifts(:,:,r)] = o.AmendShifts(o.D0(:,:,r),Scores(:,r),'FindSpots');
end

o.FindSpotsInfo.Scores = Scores;
o.FindSpotsInfo.ChangedSearch = ChangedSearch;
o.FindSpotsInfo.Outlier = OutlierShifts;

save(fullfile(o.OutputDirectory, 'FindSpotsWorkspace.mat'), 'o', 'AllBaseLocalYXZ');

o = o.PointCloudRegister_NoAnchor3DWithCA(AllBaseLocalYXZ, o.RawLocalYXZ, nTiles);

save(fullfile(o.OutputDirectory, 'FindSpotsWorkspace.mat'), 'o', 'AllBaseLocalYXZ');
%% decide which tile to read each spot off in each round. 
% They are read of home tile if possible (always possible in ref round)
% in other rounds might have to be a NWSE neighbor - but never a diagonal
% neighbor
% ndRoundTile(s,r) stores appropriate tile for spot s on round r
% ndRoundYX(s,:,r) stores YX coord on this tile

%Compute approx new shifts in XY pixels, by taking the bottom row of the
%transform R. Then convert z shift back to units of z pixels for origin
%THIS PART NEEDS WORK - NOT SURE IT IS THAT CRUCIAL THOUGH
XYPixelShifts = permute(squeeze(o.A(4,:,:,1:o.nRounds,o.InitialShiftChannel).*[1,1,o.XYpixelsize/o.Zpixelsize]),[2 1 3]);
o.TileOrigin(:,:,1:o.nRounds) =  o.TileOrigin(:,:,rr) - XYPixelShifts(:,:,1:o.nRounds);     

ndRoundTile = nan(nnd,o.nRounds);
ndRoundYXZ = nan(nnd,3,o.nRounds);

PossNeighbs = [-1 -nY 1 nY 0]; % NWSE then same tile - same will have priority by being last

for r=o.UseRounds
    fprintf('Finding appropriate tiles for round %d\n', r);
    
    for n = PossNeighbs
        % find origins of each tile's neighbor, NaN if not there
        NeighbTile = (1:nTiles)+n;
        NeighbOK = (NeighbTile>=1 & NeighbTile<=nTiles);
        NeighbOrigins = nan(nTiles,3);
        NeighbOrigins(NeighbOK,:) = round(o.TileOrigin(NeighbTile(NeighbOK),:,r));
        
        % now for each spot see if it is inside neighbor's tile area
        SpotsNeighbOrigin = NeighbOrigins(ndLocalTile,:);
        SpotsInNeighbTile = all(ndGlobalYXZ>=SpotsNeighbOrigin+1+o.ExpectedAberration...
            & ndGlobalYXZ<=SpotsNeighbOrigin+o.TileSz-o.ExpectedAberration, 2);
        
        % for those that were in set this to be its neighbor
        ndRoundTile(SpotsInNeighbTile,r) = NeighbTile(ndLocalTile(SpotsInNeighbTile));    
    end
    
    % compute YXZ coord
    HasTile = isfinite(ndRoundTile(:,r));
    ndRoundYXZ(HasTile,:,r) = ndGlobalYXZ(HasTile,:) - round(o.TileOrigin(ndRoundTile(HasTile,r),:,r));
    
end

%% loop through all tiles, finding spot colors

ndSpotColors = nan(nnd, o.nBP, o.nRounds);
ndPointCorrectedLocalYXZ = nan(nnd, 3, o.nRounds, o.nBP);

for t=1:nTiles
    if o.EmptyTiles(t); continue; end
    [y, x] = ind2sub([nY nX], t);
   
    for r=o.UseRounds      
        % find spots whose home tile on round r is t
        MySpots = (ndRoundTile(:,r)==t);
        if ~any(MySpots); continue; end
        
        % find the home tile for all current spots in the ref round
        RefRoundHomeTiles = ndLocalTile(ndRoundTile(:,r)==t);
        MyRefTiles = unique(RefRoundHomeTiles);
        fprintf('\nRef round home tiles for spots in t%d at (%2d, %2d), r%d: ', t, y, x, r);
        for i=MyRefTiles(:)'
            fprintf('t%d, %d spots; ', i, sum(RefRoundHomeTiles==i));
        end
        fprintf('\n');        
        
        
        % now read in images for each base
        for b=o.UseChannels              %No 0 as trying without using anchor

            
            BaseIm = o.load_3D(r,y,x,o.FirstBaseChannel + b - 1)-o.TilePixelValueShift;
            
            if o.SmoothSize
                %BaseImSm = imfilter(double(BaseIm), fspecial('disk', o.SmoothSize));
                SE = fspecial3('ellipsoid',o.SmoothSize);
                BaseImSm = imfilter(BaseIm, SE);
            else
                BaseImSm = BaseIm;
            end
            
            for t2 = MyRefTiles(:)'
                MyBaseSpots = (ndRoundTile(:,r)==t & ndLocalTile==t2);
                CenteredScaledMyLocalYXZ = [(ndLocalYXZ(MyBaseSpots,:) - o.CentreCorrection).*[1,1,o.Zpixelsize/o.XYpixelsize],...
                    ones(size(ndLocalYXZ(MyBaseSpots,:),1),1)];
                
                if t == t2
                    fprintf('Point cloud: ref round tile %d -> tile %d round %d base %d, %d/%d matches, error %f\n', ...
                        t, t2, r, b,  o.nMatches(t,b,r), size(o.RawLocalYXZ{t2},1), o.Error(t,b,r));
                    if o.nMatches(t,b,r)<o.MinPCMatches || isempty(o.nMatches(t,b,r))
                        warning('Tile %d, channel %d, round %d has %d point cloud matches, which is below the threshold of %d.',...
                            t,b,r,o.nMatches(t,b,r),o.MinPCMatches);
                    end
                    CenteredMyPointCorrectedYXZ = (CenteredScaledMyLocalYXZ*o.A(:,:,t,r,b));
                    MyPointCorrectedYXZ = round(CenteredMyPointCorrectedYXZ.*[1,1,o.XYpixelsize/o.Zpixelsize] + o.CentreCorrection);
                    ndPointCorrectedLocalYXZ(MyBaseSpots,:,r,b) = MyPointCorrectedYXZ;
                    ndSpotColors(MyBaseSpots,b,r) = IndexArrayNan(BaseImSm, MyPointCorrectedYXZ');
                else
                    [MyPointCorrectedYXZ, Error, nMatches] = o.different_tile_transform(AllBaseLocalYXZ,o.RawLocalYXZ, ...
                        CenteredScaledMyLocalYXZ,t,t2,r,b);
                    fprintf('Point cloud: ref round tile %d -> tile %d round %d base %d, %d/%d matches, error %f\n', ...
                        t, t2, r, b,  nMatches, size(o.RawLocalYXZ{t2},1), Error);
                    if nMatches<o.MinPCMatches || isempty(nMatches)
                        continue;
                    end
                    ndPointCorrectedLocalYXZ(MyBaseSpots,:,r,b) = MyPointCorrectedYXZ;
                    ndSpotColors(MyBaseSpots,b,r) = IndexArrayNan(BaseImSm, MyPointCorrectedYXZ');
                end
               
            end    
        end      
    end
end
fprintf('\n');

%% now find those that were detected in all tiles
ndSpotColorsToUse = ndSpotColors(:,o.UseChannels,o.UseRounds);
Good = all(isfinite(ndSpotColorsToUse(:,:)),2);
GoodGlobalYXZ = ndGlobalYXZ(Good,:);
GoodSpotColors = ndSpotColors(Good,:,:);
GoodLocalTile = ndLocalTile(Good);
GoodIsolated = ndIsolated(Good);
GoodAnchorChannel = ndAnchorChannel(Good);

save(fullfile(o.OutputDirectory, 'FindSpotsWorkspace.mat'), 'o', 'AllBaseLocalYXZ',...
    'Good', 'ndGlobalYXZ', 'ndSpotColors', 'ndLocalTile','ndIsolated','ndAnchorChannel','ndPointCorrectedLocalYXZ','ndRoundYXZ','ndRoundTile');

%% plot those that were found and those that weren't
if o.Graphics
    plotSpotsResolved(o,ndGlobalYXZ,Good,Tiles,'Resolved Spots')
end
       

%% sanity check
plsz = 7;
if o.Graphics ==2
    GoodRoundYXZ = ndRoundYXZ(Good,:,:);
    GoodRoundTile = ndRoundTile(Good,:);
    GoodCorrectedYXZ = ndPointCorrectedLocalYXZ(Good,:,:,:);

    roi = o.FindSpotsRoi;
    PlotSpots = find(GoodGlobalYXZ(:,1)>roi(1) & GoodGlobalYXZ(:,1)<roi(2) & GoodGlobalYXZ(:,2)>roi(3) & GoodGlobalYXZ(:,2)<roi(4)...
        & round(GoodGlobalYXZ(:,3))>roi(5)& round(GoodGlobalYXZ(:,3))<roi(6));
    
    for s=(PlotSpots(:))' %PlotSpots(randperm(length(PlotSpots)))'
        figure(s); clf
        for r=o.UseRounds
            t=GoodRoundTile(s,r);
            [yTile,xTile] = ind2sub([nY nX], t);
            fprintf('Spot %d, round %d, tile %d: y=%d, x=%d, z=%d\n', s, r, t, GoodRoundYXZ(s,1,r), GoodRoundYXZ(s,2,r), GoodRoundYXZ(s,3,r));

            Ylegends = {o.bpLabels{:}};
            for b=o.UseChannels
                
                      
%                 if b==0                    
%                     y0 = GoodRoundYX(s,1,r);
%                     x0 = GoodRoundYX(s,2,r);
%                 else
%                     y0 = GoodCorrectedYX(s,1,r,b);
%                     x0 = GoodCorrectedYX(s,2,r,b);
%                 end
                y0 = GoodCorrectedYXZ(s,1,r,b);
                x0 = GoodCorrectedYXZ(s,2,r,b);
                z = round(GoodCorrectedYXZ(s,3,r,b));
                if ~isfinite(x0) || ~isfinite(y0)
                    continue;
                end
                y1 = max(1,y0 - plsz);
                y2 = min(o.TileSz,y0 + plsz);
                x1 = max(1,x0 - plsz);
                x2 = min(o.TileSz,x0 + plsz);
           
                BaseIm = imread(o.TileFiles{r,yTile,xTile,o.FirstBaseChannel + b - 1}, z, 'PixelRegion', {[y1 y2], [x1 x2]})-o.TilePixelValueShift;
                if o.SmoothSize
                    SE = fspecial3('ellipsoid',o.SmoothSize); 
                    BaseImSm = imfilter(BaseIm, SE);
                else
                    BaseImSm = BaseIm;
                end

                subplot(o.nBP, o.nRounds, (b-1)*o.nRounds + r)
                imagesc([x1 x2], [y1 y2], BaseImSm); hold on
                axis([x0-plsz, x0+plsz, y0-plsz, y0+plsz]);
                plot(xlim, [y0 y0], 'w'); plot([x0 x0], ylim, 'w');
                caxis([0 o.AutoThresh(t,b,r)*2]);
                if r==1; ylabel(Ylegends{b}); end
                colorbar;
                
                title(sprintf('Round %d, Base %d, Tile %d', r, b, t));
                drawnow
            end
        end
        fprintf('\n');
        %figure(92); clf
        %imagesc(sq(GoodSpotColors(s,:,:)));
        %set(gca, 'ytick', 1:5); set(gca, 'yticklabel', {'Anchor', o.bpLabels{:}});
        %caxis([0 o.DetectionThresh*2]);
%         fprintf('local YX = (%f, %f) screen YX = (%f, %f) Called as %s, %s, quality %f\n', ...
%             GoodRoundYX(s,1), GoodRoundYX(s,2), GoodGlobalYX(s,1)/4, GoodGlobalYX(s,2)/4, ...
%             GoodCodes{s}, GoodGenes{s}, GoodMaxScore(s));
        %figure(1003); hold on
        %squarex = [-1 1 1 -1 -1]*plsz; squarey = [-1 -1 1 1 -1]*plsz;
        %h = plot(GoodGlobalYXZ(s,2)+squarex, GoodGlobalYXZ(s,1)+squarey, 'g');
        %pause;
        %delete(h);
    end
end



o.SpotGlobalYXZ = GoodGlobalYXZ;
o.cSpotColors = GoodSpotColors;          
%o.cAnchorIntensities = squeeze(GoodSpotColors(:,1,:));
o.cSpotIsolated = GoodIsolated;
o.cSpotAnchorChannel = GoodAnchorChannel;

