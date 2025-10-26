-----------------------------------------------------------------------------------
-- Improvement suggestions for the current design
Áp dụng một servlet Front Controller + Command pattern để gom xử lý điều hướng, giảm trùng lặp trong từng servlet.
Thêm tầng Service giao diện (interface + implementation) để test độc lập và chuẩn bị cho DI khi chuyển sang Spring sau này.
Chuẩn hóa DTO/ViewModel và mapper (ví dụ MapStruct hoặc mapper thủ công dùng utility) để tách hẳn entity khỏi JSP.
Triển khai connection pool (HikariCP) và transaction helper ở Service giúp quản lý JDBC hiệu quả hơn.
Sử dụng thư viện logging (Log4j2, SLF4J) thay vì System.out.println để ghi log chuyên nghiệp.
-----------------------------------------------------------------------------------
-- 1. Use case need to be implemented
-----------------------------------------------------------------------------------
ID,Use Case,Actors,Use Case Description
UC-01,Register,Guest,"Let Guest Register an Account to get Access to more features, Register process include entering details and confirming OTP. "
UC-02,Send OTP,Guest,Send an OTP to Guest during the Register process to confirm identity. 
UC-03,View All Trip,"Guest, Customer",Let Users view all current or future available trips. 
UC-04,Search For Trips,"Guest, Customer",Allow Users to search for a specific trip. 
UC-05,View trip details,"Guest, Customer",Allow Users to view detailed information about a trip they selected. 
UC-06,Ticket Payment,"Guest, Customer",User Start Process to buy a ticket for a trip they choose 
UC-07,Select seats,"Guest, Customer",Let User Select a still available seat on the bus. 
UC-08,Reserve seats,"Guest, Customer","Let User Reserve the seat the choose, not letting other Users select the same seat. "
UC-09,Payment,"Guest, Customer",Allow Users to pay for their ticket using E-bank or other payment methods. 
UC-10,Get E-Ticket,"Guest, Customer",Send User an Electronic Ticket to use after payment 
UC-11,Cancel Ticket/Request Refund,"Guest, Customer",Allow Users to Cancel a ticket that they have paid for and issued a refund after verifying. 
UC-12,Login,"Customer, Staff, Admin, Bus Operator","Allow Users to Login into their registered account or Given account for Staff, Admin and Bus Operator. "
UC-13,Forget Password,Customer,Allow Users to change their password when they forgot their password. 
UC-14,Logout,"Customer, Staff, Admin, Bus Operator",Allow Users to logout of their logged in account. 
UC-15,Profile Management,Customer,Allow customers to manage their profile to their liking. 
UC-16,View Profile,Customer,"Let customers view their personal information, including name, phone number, address… "
UC-17,Update Profile,Customer,"Let customers update their personal information like name, phone, address if there are any changes. "
UC-18,Purchased Tickets Management,Customer,Let customers manage their purchased tickers 
UC-19,View Ticket Purchase History,Customer,Let customers see their Purchase History of past or current tickets. 
UC-20,Search Ticket,Customer,Allow customers to search for a ticket in their Purchase history. 
UC-21,Trip Review,Customer,Allow customers to write a review for a trip to express their level of satisfaction. 
UC-22,Create Physital Ticket,"Staff, Admin",Allow management to print physical tickets for customers at the counter. 
UC-23,Ticket Management,"Staff, Admin","Allow management to manage tickets including viewing, creating, and updating. "
UC-24,View Tickets,"Staff, Admin",Allow management to view all tickets in the database. 
UC-25,Create Ticket,"Staff, Admin",Allow management to create a new ticket and add it to the database. 
UC-26,Update Ticket,"Staff, Admin",Allow management to update a specific ticket detail and apply it to the database. 
UC-27,Change Ticket,"Staff, Admin",Let the management change a customer ticket if they requested a seat change or trip change. 
UC-28,Verify Ticket,"Staff, Admin","Verify customer tickets as a valid, unused ticket. "
UC-29,Customer Support,"Staff, Admin",Management assists the Customer if they have contacted Customer Support. 
UC-30,Customer Management,"Staff, Admin","Let management manage Customers, like viewing all customers and updating them. "
UC-31,View Customer,"Staff, Admin",Let management view all customers that have registered into the system. 
UC-32,Update Customer,"Staff, Admin",Let management update customer account details and status if necessary. 
UC-33,Staff Management,Admin,"Let the admin manage all the staff including viewing, creating, updating and deleting all the staff. "
UC-34,View Staff,Admin,Let the admin view all staff currently working in the system. 
UC-35,Create Staff,Admin,Let the admin create new staff accounts for a new staff. 
UC-36,Update Staff,Admin,"Let the admin update a specific staff account detail like username, password, phone number… "
UC-37,Delete Staff,Admin,Let the admin delete a staff account of their choosing removing it from the system. 
UC-38,Bus Operator Management,Admin,"Let the admin manage all Bus Operators in the system, including view, create, update and delete. "
UC-39,View Bus Operator,Admin,Let the admin view all Bus Operators currently in the system. 
UC-40,Create Bus Operator,Admin,Let the admin create a new Bus Operator account and add it to the system. 
UC-41,Update Bus Operator,Admin,"Let the admin update a specific Bus Operator account detail, like username, password, phonenum, address and apply it to the system. "
UC-42,Delete Bus Operator,Admin,Let the admin delete a specific Bus Operator account of their choosing removing it from the system. 
UC-43,Delete Ticket,Admin,Let the admin Delete a ticket from the system if the situation called for it. 
UC-44,Trip Management,Admin,"Let the admin Manage all the trips in the system, including viewing all trips, creating new trips, updating an existing trip, deleting an existing trip. "
UC-45,View Trip,Admin,Let the admin view all trips currently inside the system database. 
UC-46,Create Trip,Admin,"Let the admin create a new trip and add it to the system database, and show up on the page for the user to browse. "
UC-47,Update Trip,Admin,"Let the admin update an existing trip information, like destination, depart time, price or price and apply it to the system database. "
UC-48,Delete Trip,Admin,"Let the admin delete an existing trip from the system database, "
UC-49,Delete Account,Admin,"Let the admin Delete a customer account if the situation required it to be, like violated user agreement, or abandoned account. "
UC-50,View Sales Report/Statistics,Admin,"Let the admin view the sales report, statistic of the tickets, revenue to assist in future decision making. "
UC-51,Vehicle Info Management,Bus Operator,Let the BO manage their vehicles that have been registered. 
UC-52,View Vehicle,Bus Operator,Let the BO view all vehicles that are registered in the system and stored in garages. 
UC-53,Create Vehicle,Bus Operator,Let the BO register a new Vehicle into the server database for operations. 
UC-54,Update Vehicle,Bus Operator,"Let the BO update Vehicle information, like number, license plate, registration details. "
UC-55,Delete Vehicle,Bus Operator,Let the BO delete a Vehicle from the system database removing it from operations. 
UC-56,Update Trip Status,Bus Operator,"Let the BO update their trip status, before starting, during the trip or during arrival. "
UC-57,Handle Disruption & Notify Staff,Bus Operator,The BO handles any disruption before or during the trip and notify staff. 
UC-58,Confirm Passenger Manifest per Trip,Bus Operator,The BO confirms every present passenger ticket and updates it to the system before each trip. 
-----------------------------------------------------------------------------------
