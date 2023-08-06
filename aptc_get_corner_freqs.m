function CornerFreqs = aptc_get_corner_freqs(presentationMode, filterType, numActiveElectrodes)
% Returns list of corner frequencies based on the presentation mode, filter
% type and number of active electrodes. From the AB document: 
% "FilterCorners_NaidaQ_NaidaM_Share_MEEI.docx".
%

NaidaQ_Standard = ...
{[306	986	2005	8054]	 	 	 	 	 	 	 	 	 	 	 	 
[306	782	1393	2481	8054]	 	 	 	 	 	 	 	 	 	 	 
[306	714	1121	1733	2821	8054]	 	 	 	 	 	 	 	 	 	 
[306	646	918	1393	2073	3093	8054]	 	 	 	 	 	 	 	 	 
[306	578	850	1189	1665	2345	3364	8054]	 	 	 	 	 	 	 	 
[306	578	782	1054	1393	1869	2549	3500	8054]	 	 	 	 	 	 	 
[306	510	714	918	1189	1597	2073	2753	3636	8054]	 	 	 	 	 	 
[306	510	646	850	1054	1393	1801	2277	2957	3772	8054]	 	 	 	 	 
[306	510	646	782	986	1257	1529	1937	2481	3093	3908	8054]	 	 	 	 
[306	510	646	714	918	1121	1393	1733	2141	2617	3229	4044	8054]	 	 	 
[306	510	578	714	850	1054	1257	1529	1869	2277	2753	3364	4112	8054]	 	 
[306	442	578	646	782	986	1189	1393	1665	2005	2413	2889	3500	4180	8054]	 
[306	442	578	646	782	918	1054	1257	1529	1801	2141	2549	3025	3568	4248	8054]};

len_NaidaQ_Standard = cellfun(@length, NaidaQ_Standard);

NaidaQ_ExtendedLow = ...
{[238	986	2005	8054]												
[238	782	1393	2481	8054]											
[238	714	1121	1733	2821	8054]										
[238	646	918	1393	2073	3093	8054]									
[238	578	850	1189	1665	2345	3364	8054]								
[238	578	782	1054	1393	1869	2549	3500	8054]							
[238	510	714	918	1189	1597	2073	2753	3636	8054]						
[238	510	646	850	1054	1393	1801	2277	2957	3772	8054]					
[238	510	646	782	986	1257	1529	1937	2481	3093	3908	8054]				
[238	510	646	714	918	1121	1393	1733	2141	2617	3229	4044	8054]			
[238	510	578	714	850	1054	1257	1529	1869	2277	2753	3364	4112	8054]		
[238	442	578	646	782	986	1189	1393	1665	2005	2413	2889	3500	4180	8054]	
[238	442	578	646	782	918	1054	1257	1529	1801	2141	2549	3025	3568	4248	8054]};

len_NaidaQ_ExtendedLow = cellfun(@length, NaidaQ_ExtendedLow);


NaidaM_Standard = ...
{[270	981	1949	10000]	 	 	 	 	 	 	 	 	 	 	 	 
[270	799	1385	2401	10000]	 	 	 	 	 	 	 	 	 	 	 
[270	696	1102	1744	2760	10000]	 	 	 	 	 	 	 	 	 	 
[270	632	941	1402	2088	3110	10000]	 	 	 	 	 	 	 	 	 
[270	600	843	1186	1667	2343	3294	10000]	 	 	 	 	 	 	 	 
[270	580	781	1051	1415	1904	2563	3450	10000]	 	 	 	 	 	 	 
[270	537	706	928	1221	1605	2111	2776	3650	10000]	 	 	 	 	 	 
[270	510	655	841	1080	1388	1782	2289	2939	3775	10000]	 	 	 	 	 
[270	475	601	761	962	1218	1541	1950	2467	3122	3950	10000]	 	 	 	 
[270	481	595	735	908	1123	1388	1716	2121	2621	3240	4005	10000]	 	 	 
[270	483	587	714	867	1054	1281	1557	1893	2300	2796	3398	4130	10000]	 	 
[270	463	556	669	804	966	1161	1395	1676	2014	2421	2909	3496	4202	10000]	 
[270	457	542	643	763	905	1074	1274	1512	1793	2128	2524	2995	3553	4215	10000]};

len_NaidaM_Standard = cellfun(@length, NaidaM_Standard);

NaidaM_ExtendedLow = ...
{[200	981	1949	10000]	 	 	 	 	 	 	 	 	 	 	 	 
[200	799	1385	2401	10000]	 	 	 	 	 	 	 	 	 	 	 
[200	696	1102	1744	2760	10000]	 	 	 	 	 	 	 	 	 	 
[200	632	941	1402	2088	3110	10000]	 	 	 	 	 	 	 	 	 
[200	600	843	1186	1667	2343	3294	10000]	 	 	 	 	 	 	 	 
[200	580	781	1051	1415	1904	2563	3450	10000]	 	 	 	 	 	 	 
[200	537	706	928	1221	1605	2111	2776	3650	10000]	 	 	 	 	 	 
[200	510	655	841	1080	1388	1782	2289	2939	3775	10000]	 	 	 	 	 
[200	475	601	761	962	1218	1541	1950	2467	3122	3950	10000]	 	 	 	 
[200	481	595	735	908	1123	1388	1716	2121	2621	3240	4005	10000]	 	 	 
[200	483	587	714	867	1054	1281	1557	1893	2300	2796	3398	4130	10000]	 	 
[200	463	556	669	804	966	1161	1395	1676	2014	2421	2909	3496	4202	10000]	 
[200	457	542	643	763	905	1074	1274	1512	1793	2128	2524	2995	3553	4215	10000]};    

len_NaidaM_ExtendedLow = cellfun(@length, NaidaM_ExtendedLow);

if strcmp(presentationMode, 'Naida Q ComPilot') || strcmp(presentationMode, 'Naida Q Connect')
   if strcmp(filterType, 'Standard')
      ifilt = len_NaidaQ_Standard == numActiveElectrodes;
      CornerFreqs = cell2mat(NaidaQ_Standard(ifilt, :));
   else
      ifilt = len_NaidaQ_ExtendedLow == numActiveElectrodes;
      CornerFreqs = cell2mat(NaidaQ_ExtendedLow(ifilt, :));
   end

elseif strcmp(presentationMode, 'Naida M Bluetooth')
   if strcmp(filterType, 'Standard')
      ifilt = len_NaidaM_Standard == numActiveElectrodes;
      CornerFreqs = cell2mat(NaidaM_Standard(ifilt, :));
   else
      ifilt = len_NaidaM_ExtendedLow == numActiveElectrodes;
      CornerFreqs = cell2mat(NaidaM_ExtendedLow(ifilt, :));
   end

else % normal hearing
    CornerFreqs = cell2mat(NaidaQ_Standard(end,:));
end
