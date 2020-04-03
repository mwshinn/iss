function change_gene_symbols(MarkerSize, FontSize, MultiCol)
% ChangeGeneSymbols(MarkerSize, FontSize, nPerCol);
%
% changes gene symbols so in situ plots look nice. 
% MarkerSize defaults to 6 - if 0, won't change existing sizes
%
% FontSize is font size for legend
%
% nPerCol says how many legend entries per column (0 for one-column)
% 
% Kenneth D. Harris, 29/3/17
% GPL 3.0 https://www.gnu.org/licenses/gpl-3.0.en.html
 
if nargin<1 || isempty(MarkerSize)
    MarkerSize = 6;
end

if nargin<2 || isempty(FontSize)
    FontSize = 5;
end

if nargin<3
    MultiCol = 49;
end


% colors
non_neuron = hsv2rgb([0 0 1]);
pc_or_in =   hsv2rgb([.4 .5 .5]);
less_active =   hsv2rgb([.3 .2 .7]);
pc =        hsv2rgb([1/3 1 1]);
pc2 =       hsv2rgb([.27 1 .7]);
in_general = hsv2rgb([2/3 1 1]);
mg =         hsv2rgb([1 .5 1]);
mg2 =        hsv2rgb([1 .3 .9]);

sst =   hsv2rgb([.55 1 1]);
pvalb = hsv2rgb([.7 .8 1]);
ngf =   hsv2rgb([.85 1 1]);
cnr1 =  hsv2rgb([ 1 1 1]);
vip =   hsv2rgb([ .13 1 1]);
cxcl14= hsv2rgb([.1 1 .6]);


% All symbols: +o*.xsd^v<>ph - have them in that order to not get confused
New_symbols = {...
    
    'Snca',     in_general, '+'; ...
    'Cplx2',    in_general, '.'; ...
    'Lhx6',     in_general, 's'; ...
    'Col25a1',  in_general, '^'; ...
    'Pnoc',     in_general, '>'; ...
    'Rab3c',    in_general, '<'; ...
    'Gad1',     in_general, 'p'; ...   
    'Slc6a1',   in_general, 'h'; ...
    
    
    'Th',       sst, '+'; ...
    'Crhbp',    sst, 'o'; ...
    'Sst',      sst, '*'; ...
    'Npy',      sst, '.'; ...
    'Synpr',    sst, 'x'; ...
    'Chodl',    sst, 's';...
    'Cort',     sst, 'd'; ...
    'Reln',     sst, '^'; ...
    'Serpini1', sst, '<'; ...
    'Satb1',    sst, '>'; ...
    'Grin3a',   sst, 'p'; ...
    
    'Tac1',     pvalb, 'o'; ...
    'Pvalb',    pvalb, '*'; ...
    'Kcnip2',   pvalb, 's'; ...
    'Thsd7a',   pvalb, 'd'; ...
    'Cox6a2',   pvalb, 'v'; ...
    'Chrm2',    pvalb, 'p'; ...
    
    'Id2',      ngf, '+'; ...
    'Hapln1',   ngf, 'o'; ...
    'Gabrd',    ngf, '*'; ...
    'Cryab',    ngf, 'x'; ...
    'Kit',      ngf, 's'; ...
    'Ndnf',     ngf, 'd'; ...
    'Nos1',     ngf, '^'; ...
    'Lamp5',    ngf, '>'; ...
    'Cplx3',    ngf, 'h'; ...

    'Cadps2',   cxcl14, 'o'; ...
    'Cxcl14',   cxcl14, '*'; ...
    'Ntng1',    cxcl14, 's'; ...
    'Cpne5',    cxcl14, 'd'; ...
    'Rgs12',    cxcl14, 'h'; ...
    
% All symbols: +o*.xsd^v<>ph - have them in that order to not get confused

    'Sncg',     cnr1, 'o'; ...
    'Cnr1',     cnr1, '*'; ...
    'Cck',      cnr1, '.'; ...
    'Trp53i11', cnr1, 'x'; ...
    'Sema3c',   cnr1, 's'; ...
    'Syt6',     cnr1, '^'; ...
    'Yjefn3',   cnr1, 'v'; ...
    'Rgs10',    cnr1, '>'; ...
    'Nov',      cnr1, '<'; ...
    'Kctd12',   cnr1, 'p'; ...
    'Slc17a8',  cnr1, 'h'; ...
    
    'Tac2',     vip, '+'; ...
    'Npy2r',    vip, 'o'; ...
    'Calb2',    vip, '*'; ...
    'Htr3a',    vip, '.'; ...
    'Slc5a7',   vip, 'x'; ...
    'Penk',     vip, 's';...
    'Pthlh',    vip, '^'; ...
    'Vip',      vip, 'v'; ...
    'Crh',      vip, '>'; ...
    'Qrfpr',    vip, 'p'; ...
    
    
% All symbols: +o*.xsd^v<>ph - have them in that order to not get confused
    'Zcchc12',  less_active, '+'; ...
    'Calb1',    less_active, '*';...
    'Vsnl1',    less_active, '.'; ...
    'Tmsb10',   less_active, 'd'; ...
    'Rbp4',     less_active, 'v'; ...
    'Fxyd6',    less_active, '^'; ...
    '6330403K07Rik',    less_active, '<'; ...
    'Scg2',     less_active, '>'; ...
    'Gap43',    less_active, 'p'; ...
    'Nrsn1',    less_active, 'h'; ...
    
        
    'Gda',      pc_or_in, '+'; ...
    'Bcl11b',   pc_or_in, 'o'; ...
    'Rgs4',     pc_or_in, '*'; ...
    'Slc24a2',  pc_or_in, '.'; ...
    'Lphn2',    pc_or_in, 'x'; ...
    'Map2',     pc_or_in, 's'; ...
    'Prkca',    pc_or_in, 'd'; ...
    'Cdh13',    pc_or_in, '^'; ...
    'Atp1b1',   pc_or_in, 'v'; ...
    'Pde1a',    pc_or_in, '<'; ...
    'Calm2',    pc_or_in, '>'; ...
    'Sema3e',   pc_or_in, 'h'; ...
    

    
    'Nrn1',     pc, '*'; ...
    'Pcp4',     pc, '.'; ...
    'Rprm',     pc, '+'; ...
    'Enpp2',    pc, 'x';...
    'Rorb',     pc, 'o'; ...
    'Rasgrf2',  pc, 's'; ...
    'Wfs1',     pc, 'd'; ...
    'Fos',      pc, '>'; ...
    'Plcxd2',   pc, 'v'; ...
    'Crym',     pc, '<'; ...
    '3110035E14Rik', pc, '^'; ...
    'Foxp2',    pc, 'p';...
    'Pvrl3',    pc, 'h'; ...
    
    'Neurod6',  pc2, '+'; ...
    'Nr4a2',    pc2, 'o'; ...
    'Cux2',     pc2, '*'; ...
    'Kcnk2',    pc2, '.'; ...
    'Arpp21',   pc2, 's'; ...
    'Enc1',     pc2, 'v'; ...
    'Fam19a1',  pc2, '>'; ...

    
    'Vim',      non_neuron, '*'; ...
    'Slc1a2',   non_neuron, '.'; ...
    'Pax6',     non_neuron, 's'; ...
    'Plp1',     non_neuron, 'x'; ...
    'Mal',      non_neuron, '+'; ...
    'Aldoc',    non_neuron, 'o'; ...
    'Actb',     non_neuron, 'v'; ...
    'Sulf2',    non_neuron, 'p'; ...
    'Artificial',non_neuron,'<'; ...


    'Atp6v0d2', mg, '+'; ...
    'Bin1',     mg, 'o'; ...
    'Bin2',     mg, '*'; ...
    'C1qa',     mg, 'x'; ...
    'C1qB',     mg, 's'; ...
    'C1qC',     mg, 'd'; ...
    'Ccr5',     mg, '^'; ...
    'Csf1r',    mg, 'v'; ...
    'Cx3cr1',   mg, '<'; ...
    'Cyfip1',   mg, '>'; ...
    'Grn',      mg, 'p'; ...
    'Laptm5',   mg, 'h'; ...

    'Olfml3',   mg2, '+'; ...
    'P2ry12',   mg2, 'o'; ...
    'Plcg2',    mg2, '*'; ...
    'Pld3',     mg2, 'x'; ...
    'Pld4',     mg2, 's'; ...
    'Ptk2b',    mg2, 'd'; ...
    'Sparc',    mg2, '^'; ...
    'Tmem119',  mg2, 'v'; ...

    };

% delete any existing legend
fc = get(gcf, 'Children');
for i=1:length(fc)
    if strcmp(get(fc(i), 'UserData'), 'key')
        delete(fc(i));
    end
end

MainAxes = gca;

n =  size(New_symbols,1);

gc = get(MainAxes, 'children');
MyChildren = [];
for i=1:length(gc)
    if (strcmp(gc(i).Type, 'line') || strcmp(gc(i).Type, 'scatter')) ...
            && ~isempty(gc(i).DisplayName)
        MyChildren = [MyChildren; i];
    end
end
DisplayNames = {gc(MyChildren).DisplayName};
% get first word of display name as gene
GeneNames = cell(size(DisplayNames));
for i=1:length(DisplayNames)
    GeneNames{i} = strtok(DisplayNames{i});
end
    
clear h s;
j=1;
Present = [];
for i=1:n
    MyGeneName = New_symbols{i,1};
    l = find(strcmp(MyGeneName, GeneNames));
    if ~isempty(l)
        h(j) = gc(MyChildren(l));
		if strcmp(h(j).Type, 'line')
			set(h(j), 'Color', New_symbols{i,2});
        elseif strcmp(h(j).Type, 'scatter')
			set(h(j), 'CData', New_symbols{i,2});
		end
        set(h(j), 'Marker', New_symbols{i,3});

        if MarkerSize>0
			if strcmp(gc(l).Type, 'line')
				set(h(j), 'MarkerSize', MarkerSize);
			elseif strcmp(gc(l).Type, 'scatter')
				set(h(j), 'SizeData', MarkerSize);
			end
        end
        Present(j) = i;
        j=j+1;
    end
end

other_h = setdiff(gc(MyChildren), h);
other_symbols = {other_h.DisplayName};

all_h = [h(:); other_h(:)];
all_sym = {New_symbols{Present,1}, other_symbols{:}};

% lh = legend([h(:); other_h(:)], ...
%     {New_symbols{s,1}, other_symbols{:}}, ...
%     'color', 'k', 'textcolor', 'w', 'fontsize', FontSize);
% set(lh, 'color', 'k');
% 
% return;

if MultiCol==0
    lh = legend(all_h, all_sym, 'color', 'k', 'textcolor', 'w', 'fontsize', FontSize);
    set(lh, 'color', 'k');
else
    ah = axes('Position', [.925 .13 .05 .8]);
    set(ah, 'color', 'k'); cla; hold on; box off
    set(ah, 'UserData', 'key');
    for j=1:length(Present)
        i = Present(j);
        plot(ceil(j/MultiCol)+.1, mod(j-1,MultiCol), New_symbols{i,3}, 'Color', New_symbols{i,2});
        text(ceil(j/MultiCol)+.3, mod(j-1,MultiCol), New_symbols{i,1}, 'color', 'w', 'fontsize', FontSize);
    end
    ylim([-1 MultiCol]);
    set(ah, 'xtick', []);
    set(ah, 'ytick', []);
    set(ah, 'ydir', 'reverse');
end
%     for c=1:nCols
%         rr=((c-1)*50 + 1):min(c*50, length(all_h));
%         if c==1
%             ah(c) = gca;
%             lh(c) = legend(all_h(rr), all_sym(rr), 'color', 'k', 'textcolor', 'w', 'fontsize', FontSize, 'location', 'east');
%             set(lh(c), 'color', 'k');
%             pos(c,:) = get(lh(c), 'position');
%         else
%             ah(c) = axes('position',get(gca,'position'), 'visible','off');
%             lh(c) = legend(ah(c), all_h(rr), all_sym(rr), 'color', 'k', 'textcolor', 'w', 'fontsize', FontSize, 'location', 'east');
%             set(lh(c), 'position', pos(c-1,:) + [1.1 0 0 0]*pos(c-1,3));
%             uistack(lh(c), 'top');
%         end
%     end
%     axes(ah(1));
    
%    error('multicolumn not done yet!');
% end
%     for i=1:nCols
%         first = 1+(i-1)*nCols;
%         last = min(i*nCols,length(all_h));
%         lh = legend(all_h(first:last), ...
%             all_sym{first:last});%, ...
%             %'color', 'k', 'textcolor', 'w', 'fontsize', FontSize);
%         set(lh, 'color', 'k');
%     end
set(gcf, 'color', 'k');
set(gcf, 'InvertHardcopy', 'off');
    
axes(MainAxes)
uistack(ah, 'top');

end