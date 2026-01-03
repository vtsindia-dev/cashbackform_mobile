class ApiUrl {
  static const String baseUrl = "http://192.168.1.114/admincashback/public";
  // static const String baseUrl = "https://admincashback.vrikshatech.in/public";
  static const String login = "$baseUrl/api/v2/login";
  static const String otp = "$baseUrl/api/v2/otp";
  static const String register = "$baseUrl/api/v2/register";
  static const String removeAccount = "$baseUrl/api/v2/remove-account";

  // Profile
  static const String getProfile = "$baseUrl/api/v2/get_profile";
  static const String profileUpdate = "$baseUrl/api/v2/profile_update";
  static const String dashBoard = "$baseUrl/api/v2/dashboard";
  // Plots
  static const String syndicatePlotList = "$baseUrl/api/v2/synticate";
  static const String giooPlotList = "$baseUrl/api/v2/geo";
  static const String marketPlotList = "$baseUrl/api/v2/market";
  // Plot Details
  static const String syndicateDetails = "$baseUrl/api/v2/property_details/synticate";
  static const String giooDetails = "$baseUrl/api/v2/property_details/geo";
  static const String marketDetails = "$baseUrl/api/v2/property_details/market";
  static const String sendMarketEnquiry = "$baseUrl/api/v2/market_enquiry";
  // Market/Store
  static const String marketList = "$baseUrl/api/v2/material_list";
  static const String marketPlotAdd = "$baseUrl/api/v2/market_store";
  static const String marketPlotEdit = "$baseUrl/api/v2/market_update";
  static const String marketPlotDelete = "$baseUrl/api/v2/marketdelete";
  // Services
  static const String serviceList = "$baseUrl/api/v2/services_list";
  static const String serviceDetail = "$baseUrl/api/v2/services_list";
  // Materials
  static const String materialDetail = "$baseUrl/api/v2/material";
  // Enquiries
  static const String materialEnquiry = "$baseUrl/api/v2/material_enquiry";
  static const String serviceEnquiry = "$baseUrl/api/v2/service_enquiry";
  static const String plotEnquiry = "$baseUrl/api/v2/plot_enquiry";
  // In ApiUrl class, add:
  static const String myServicesList = "$baseUrl/api/v2/my_services_list";
  // Other endpoints (add as needed)
  static const String contactUs = "$baseUrl/api/v2/pages/slug/contact_page";
  static const String aboutUs = "$baseUrl/api/v2/pages/slug/about_us";
  static const String faq = "$baseUrl/api/v2/faq";
  static const String terms = "$baseUrl/api/v2/terms";
  static const String privacy = "$baseUrl/api/v2/privacy";


  static const String carouselBanners = '$baseUrl/api/v2/carousel_banner';
  static const String featuredSyndicates = '$baseUrl/api/v2/synticate/featured';
  static const String featuredMarket = '$baseUrl/api/v2/market/featured';
  static const String featuredGioo = "$baseUrl/api/v2/geo/featured";

  static const String giooBuyingList = '$baseUrl/api/v2/gioo_buying_list';
  static const String giooBuyingListDetails = '$baseUrl/api/v2/gioo_buying_list_details';
  static const String giooBuyingCancelRequest = '$baseUrl/api/v2/gioo_buying_cancel_request';
// static const String featuredMarket = '$baseUrl//api/v2/market/featured';
}