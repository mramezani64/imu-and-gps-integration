function export_kml_p(Name, Position, Strings, colour, size)

% A function that creates a .kml file which is used to view the path in
% Google Earth.
% Input: Name, Time, Position.
% Name is a string that specifies the name of desired file.
% Position is a 3 X N matrix where N is the total number of position. Each
% column specifies the position (latitude;longtitude;altitude) at each
% location.

% 31/10/2013

% header = ['<?xml version="1.0" encoding="UTF-8"?> <kml xmlns="http://earth.google+.com/kml/2.0"> <Document> <Placemark> <name>Path</name> <description>Path created from GPS/INS Integration</description> <visibility>1</visibility> <Style id="fix3"> <LineStyle> <color>ff0000ff</color> <width>2</width> </LineStyle> </Style> <MultiGeometry> <LineString> <tessellate>1</tessellate> <altitudeMode>clampedToGround</altitudeMode> <coordinates>'];
% footer = ['</coordinates> </LineString> </MultiGeometry> </Placemark> </Document> </kml>'];

header = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom"><Document>';

if strcmp('red', colour);           col = 'ff0000ff';
elseif strcmp('green', colour);     col = 'ff00ff00';
elseif strcmp('blue', colour);      col = 'ffff0000';
elseif strcmp('yellow', colour);    col = 'ff00ffff';
else                                col = 'ff0000ff';
end

Style_s = '<Style id="1"><IconStyle><color>';
Style_m = '</color><scale>';
Style_e = '</scale><Icon><href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href></Icon></IconStyle></Style>';
Style_c = strcat(Style_s,col,Style_m,size,Style_e);

%%
fid = fopen(Name, 'wt');
fprintf(fid, '%s \n',header);   % header
fprintf(fid, '%s \n',Style_c);  % colour and marker size

n = length(Position);

% Strings
if isempty(Strings) == 1;
    str = cell(1,n);
else
    str = Strings;
end


for i = 1:n    
    
    Ext_data  = sprintf('<ExtendedData><Data name="GPS Time (s)"><value> %.2f </value></Data>' , Position(1,i));
    Ext_data1 = sprintf('<Data name="Latitude"><value> %f </value></Data>' , Position(3,i));
    Ext_data2 = sprintf('<Data name="Longitude"><value> %f </value></Data>' , Position(2,i));
    Ext_data3 = sprintf('<Data name="Height"><value> %f </value></Data>' , Position(4,i));
    Ext_data4 = sprintf('<Data name="N Sat"><value> %f </value></Data>' , Position(5,i));
    Ext_data5 = sprintf('<Data name="Other"><value> %s </value></Data></ExtendedData>' , str{1,i});
    Ext_data  = sprintf('%s %s %s %s %s %s\n', Ext_data, Ext_data1, Ext_data2, Ext_data3, Ext_data4, Ext_data5);
    
    fprintf(fid, '<Placemark><styleUrl>#1</styleUrl> %s <Point><coordinates> \n', Ext_data);    
    fprintf(fid, '%f, %f, %f \n', Position(2:4,i));
    fprintf(fid, '</coordinates></Point></Placemark>');
end

fprintf(fid, '</Document></kml>');
fclose(fid);

end