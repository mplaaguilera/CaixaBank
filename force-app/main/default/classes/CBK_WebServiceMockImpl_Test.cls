@isTest
public class CBK_WebServiceMockImpl_Test implements WebServiceMock {
    public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
            if (request instanceof MetadataService.readMetadata_element) {
                response.put('response_x', readResponse(request));
            }else {
                System.assert(false, 'Unexpected request ' + request);
            }

		}

    // Implementa respuesta service.readMetadata
    private MetadataService.IReadResponseElement readResponse(Object request) {

        MetadataService.readMetadata_element r = (MetadataService.readMetadata_element) request;

        if (r.type_x == 'Profile'){                           
            system.debug('Crear profile');

            List<MetadataService.ProfileLoginIpRange> lstips = new List<MetadataService.ProfileLoginIpRange>();
            MetadataService.ProfileLoginIpRange ips = new MetadataService.ProfileLoginIpRange();
            ips.startAddress = '1.1.1.1';
            ips.endAddress = '1.1.1.1';
            ips.description = 'test';
            lstips.add(ips);
            ips = new MetadataService.ProfileLoginIpRange();
            ips.startAddress = '3.3.3.3';
            ips.endAddress = '3.3.3.3';
            ips.description = 'test2';
            lstips.add(ips);
            ips = new MetadataService.ProfileLoginIpRange();
            ips.startAddress = '2.2.2.2';
            ips.endAddress = '2.2.2.2';
            ips.description = 'test3';
            lstips.add(ips);
            ips = new MetadataService.ProfileLoginIpRange();
            ips.startAddress = '4.4.4.4';
            ips.endAddress = '4.4.4.4';
            ips.description = 'test3';
            lstips.add(ips);

            List<MetadataService.Profile> lstprofile = new List<MetadataService.profile>();
            MetadataService.Profile profile = new MetadataService.profile();
            profile.fullName = 'API Only';
            profile.loginIpRanges = lstips;
            lstprofile.add(profile);

            MetadataService.ReadProfileResult result = new MetadataService.ReadProfileResult();
            result.records = lstprofile;

            MetadataService.readProfileResponse_element responseElement = new MetadataService.readProfileResponse_element();
            responseElement.result = result;
            return responseElement;
        }else {
            System.assert(false, 'Unexpected read type ' + r.type_x);
            return null;
        }
    }
}