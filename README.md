# 🍴 Online Food Ordering System  

A full-stack **Online Food Ordering System** built with **Flutter (frontend)** and **Spring Boot (backend)**.  
The system allows customers to browse menu items, place orders, and track their delivery, while restaurant managers can manage orders, approve/reject requests, and update order statuses.  

---

## 🚀 Features  

### 👨‍🍳 Customer Side
- Register & login securely  
- Browse menu items with details  
- Add items to cart and place an order  
- Choose payment method (Bkash, Rocket, Cash on Delivery)  
- View personal order history (`My Orders`)  
- Confirm received deliveries  

### 🏪 Restaurant Manager Side
- Register & login as a manager  
- Dashboard to view incoming orders  
- Approve or reject pending orders  
- Multi-stage order management:  
  - `PENDING` → `APPROVED` → `SHIPPED` → `DELIVERED`  
- Professional UI to filter orders by status (tabs for PENDING, APPROVED, SHIPPED, DELIVERED)  

---

## 🛠️ Tech Stack  

### Frontend (Flutter)
- Flutter 3.x  
- Provider (state management)  
- SharedPreferences (local storage for userId, login session)  
- HTTP package (API communication)  
- Clean, responsive UI design  

### Backend (Spring Boot)
- Spring Boot 3.x  
- Spring Security (authentication & authorization)  
- JPA + Hibernate (database layer)  
- MySQL (relational database)  
- REST API endpoints for full CRUD operations  

---

## 📂 Project Structure  

### Flutter (Frontend)
lib/
├── models/
│ └── order_model.dart
├── providers/
│ └── menu_item_provider.dart
├── services/
│ ├── auth_service.dart
│ ├── order_service.dart
│ └── menu_item_service.dart
├── screens/
│ ├── login_screen.dart
│ ├── register_screen.dart
│ ├── dashboard_screen.dart
│ ├── menu_item_screen.dart
│ ├── my_orders_screen.dart
│ └── pending_orders_screen.dart
└── utils/
└── user_preferences.dart

shell


### Spring Boot (Backend)
src/main/java/com/example/foodorder/
├── controller/
│ └── OrderController.java
├── dto/
│ └── OrderDto.java
├── entity/
│ ├── Order.java
│ ├── OrderItem.java
│ └── MenuItem.java
├── repository/
│ └── OrderRepository.java
└── service/
└── OrderService.java

yaml


---

## ⚡ API Endpoints (Backend)  

### Orders
- `POST /api/orders` → Place new order  
- `GET /api/orders/pending` → Get pending orders (manager)  
- `GET /api/orders/user/{userId}` → Get orders by customer  
- `PATCH /api/orders/{orderId}` → Update order status (`APPROVED`, `SHIPPED`, `DELIVERED`)  

### Authentication
- `POST /api/auth/register` → User registration (Customer/Manager)  
- `POST /api/auth/login` → User login  

---

## 📸 Screenshots  

### Customer App
![Customer Home](screenshots/customer_home.png)
![My Orders: https://prnt.sc/N8L9HnHUP7cy)
invoice: https://prnt.sc/nZZR8znNjF5P

### Manager/Admin App


> *Replace the image paths with your own screenshots*

---

## ⚙️ Installation & Setup  

### Backend (Spring Boot)
```bash
# Clone the repository
git clone https://github.com/your-username/food-order-backend.git
cd food-order-backend

# Configure MySQL in application.properties
spring.datasource.url=jdbc:mysql://localhost:3306/food_order
spring.datasource.username=root
spring.datasource.password=yourpassword

# Run the backend
./mvnw spring-boot:run
Frontend (Flutter)
bash
Copy code
# Clone the repository
git clone https://github.com/your-username/food-order-frontend.git
cd food-order-frontend

# Install dependencies
flutter pub get

# Run the app
flutter run
📖 Future Improvements
Add real-time notifications (WebSocket/FCM)

Implement payment gateway integration

Improve UI/UX with animations

Multi-language support

👨‍💻 Author
Developed by Gazi Rifat Ahmed
📧 Contact: gazirifatahmed@gmail.com
🔗 GitHub:https://github.com/gazirifatahmed
