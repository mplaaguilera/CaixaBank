public with sharing class ACA_SecureAuthenticationType {
	@InvocableMethod(label='Secure Authentication' description='ACA_SecureAuthenticationType')
	public static List<Response> secureAuthentication(List<Rquest> req) {
		List<Response> Responses = new List<Response>();

		// Hardcoding the data for example and not focusing on how we retrieve it.
		// However, consider that we are receiving available flights from a service,
		// and then iterating through the data to generate the final response.

		List<Flight> flights = new List<Flight>();
		Flight f1 = new Flight('IX 2814', 1, false, 1000L, 20.20d, 70);
		Flight f2 = new Flight('6E 488', 2, false, 2000L, 15.15d, 120);
		Flight f3 = new Flight('6E 523', 1, false, 3000L, 13.14d, 75);
		Flight f4 = new Flight('6E 6166', 2, false, 4000L, 14.14d, 130);
		flights.add(f1);
		flights.add(f2);
		flights.add(f3);
		flights.add(f4);
		AvailableFlight availableFlights = new AvailableFlight();
		availableFlights.flights = flights;

		Response fr = new Response();
		fr.aFlight = availableFlights;
		Responses.add(fr);

		return Responses;
	}

	public class Rquest {
		@InvocableVariable
		public String originCity;

		@InvocableVariable
		public String destinationCity;

		@InvocableVariable
		public Date dateOfTravel;

		@InvocableVariable
		public Filter filters;
	}

	public class Filter {
		@InvocableVariable
		public Long price;

		@InvocableVariable
		public Double discountPercentage;
	}

	public class Response {
		@InvocableVariable
		public AvailableFlight aFlight;
	}

	public class AvailableFlight {
		public List<Flight> flights;
	}

	public class Flight {
		@InvocableVariable
		public String flightId;

		@InvocableVariable
		public Integer numLayovers;

		@InvocableVariable
		public Boolean isPetAllowed;

		@InvocableVariable
		public Long price;

		@InvocableVariable
		public Double discountPercentage;

		@InvocableVariable
		public Integer durationInMin;

		public Flight(
			String flightId,
			Integer numLayovers,
			Boolean isPetAllowed,
			Long price,
			Double discountPercentage,
			Integer durationInMin
		) {
			this.flightId = flightId;
			this.numLayovers = numLayovers;
			this.isPetAllowed = isPetAllowed;
			this.price = price;
			this.discountPercentage = discountPercentage;
			this.durationInMin = durationInMin;
		}
	}
}
