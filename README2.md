# NamastePMS Backend API Documentation

This repository contains the complete API implementation for a Property Management System (PMS) for hotels and cafe/restaurant management. It includes User Registration, Authentication, Order Management, Staff Management, Guest Management, Food Items, Table Management, Room Management, Booking Management, Invoice & Payment Processing, and Dashboard APIs.

**Base URL:** `/api/`

**Authentication:** JWT Bearer Token (where required)

---

## Table of Contents

1. [Authentication & Business APIs](#authentication--business-apis)
2. [Order Management APIs](#order-management-apis)
3. [Staff Management APIs](#staff-management-apis)
4. [Guest Management APIs](#guest-management-apis)
5. [Category Management APIs](#category-management-apis)
6. [Food Item Management APIs](#food-item-management-apis)
7. [Order Item Management APIs](#order-item-management-apis)
8. [Table Management APIs](#table-management-apis)
9. [Booking Management APIs](#booking-management-apis)
10. [Room Management APIs](#room-management-apis)
11. [Invoice Management APIs](#invoice-management-apis)
12. [Payment Management APIs](#payment-management-apis)
13. [Dashboard APIs](#dashboard-apis)
14. [Revenue APIs](#revenue-apis)
15. [Super Admin APIs](#super-admin-apis)
16. [Error Codes Reference](#error-codes-reference)

---

## Authentication & Business APIs

### 1. User Signup

Registers a new user and their associated business details.

- **Endpoint:** `/api/signup/`
- **Method:** `POST`
- **Authentication:** Not Required (AllowAny)
- **Request Body:**

```json
{
  "username": "string",
  "password": "string",
  "email": "string",
  "business_name": "string",
  "phone_number": "string",
  "pan_number": "string",
  "address": "string",
  "business_type_id": "int (Foreign Key)"
}
```

#### Responses:

| Status Code                   | Scenario                 | Body                                                     |
| :---------------------------- | :----------------------- | :------------------------------------------------------- |
| **201 Created**               | Success                  | `{"message": "User and business created successfully."}` |
| **400 Bad Request**           | Missing Fields           | `{"error": "All fields are required."}`                  |
| **400 Bad Request**           | Invalid Business Type ID | `{"error": "Invalid business type ID."}`                 |
| **500 Internal Server Error** | Server Error             | `{"error": "<error_message>"}`                           |

---

### 2. Get All Users and Businesses

Retrieves all registered users along with their associated business information.

- **Endpoint:** `/api/signup/`
- **Method:** `GET`
- **Authentication:** Not Required (AllowAny)

#### Response (200 OK):

```json
{
  "users": [
    {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com",
      "businesses": [
        {
          "id": 1,
          "name": "John's Cafe",
          "phone_number": "1234567890",
          "pan_number": "ABCDE1234F",
          "address": "123 Main St",
          "business_type": "Cafe",
          "created_at": "2024-01-01T10:00:00Z",
          "updated_at": "2024-01-01T10:00:00Z"
        }
      ]
    }
  ]
}
```

#### Responses:

| Status Code                   | Scenario     | Body                           |
| :---------------------------- | :----------- | :----------------------------- |
| **200 OK**                    | Success      | `{"users": [<user_objects>]}`  |
| **500 Internal Server Error** | Server Error | `{"error": "<error_message>"}` |

---

### 3. User Login

Authenticates a user and returns JWT access and refresh tokens.

- **Endpoint:** `/api/login/`
- **Method:** `POST`
- **Authentication:** Not Required (AllowAny)
- **Request Body:**

```json
{
  "phone_number": "string",
  "password": "string"
}
```

#### Response (200 OK):

```json
{
  "message": "Login successful.",
  "tokens": {
    "refresh": "<refresh_token>",
    "access": "<access_token>"
  }
}
```

#### Additional info responses

If staff
return id, name, role, shift, status, business_uid

If business
return uid, id, name, role, username, email

#### Responses:

| Status Code                   | Scenario            | Body                                                   |
| :---------------------------- | :------------------ | :----------------------------------------------------- |
| **200 OK**                    | Success             | `{"message": "Login successful.", "tokens": {...}}`    |
| **400 Bad Request**           | Missing Fields      | `{"error": "Phone number and password are required."}` |
| **401 Unauthorized**          | Invalid Credentials | `{"error": "Invalid phone number or password."}`       |
| **500 Internal Server Error** | Server Error        | `{"error": "<error_message>"}`                         |

---

### 4. Token Refresh

Generates a new access token when the current one expires.

- **Endpoint:** `/api/refresh-token/`
- **Method:** `POST`
- **Authentication:** Not Required
- **Request Body:**

```json
{
  "refresh": "<refresh_token>"
}
```

#### Responses:

| Status Code          | Scenario              | Body                                                        |
| :------------------- | :-------------------- | :---------------------------------------------------------- |
| **200 OK**           | Success               | `{"access": "<new_access_token>"}`                          |
| **401 Unauthorized** | Invalid/Expired Token | `{"detail": "Token is invalid", "code": "token_not_valid"}` |

---

## Order Management APIs

### 5. Get Orders

Retrieves all orders or orders for a specific table.

- **Endpoint:** `/api/orders/` or `/api/orders/<table_id>/`
- **Method:** `GET`
- **Authentication:** Not Required (JWT Token)
- **URL Parameters:**
  - `table_id` (optional): Integer - Filter orders by table ID

#### Response (200 OK):

```json
{
  "orders": [
    {
      "id": 1,
      "business_id": 1,
      "order_number": "ORD-001",
      "table_id": 5,
      "guest_id": 3,
      "order_type_id": 1,
      "status_id": 2,
      "subtotal": "150.00",
      "discount": "10.00",
      "tax": "15.00",
      "total_amount": "155.00",
      "created_at": "2024-01-01T12:00:00Z",
      "updated_at": "2024-01-01T12:30:00Z"
    }
  ]
}
```

#### Responses:

| Status Code                   | Scenario              | Body                                                    |
| :---------------------------- | :-------------------- | :------------------------------------------------------ |
| **200 OK**                    | Success               | `{"orders": [<order_objects>]}`                         |
| **404 Not Found**             | Table Not Found       | `{"error": "Table with ID {table_id} does not exist."}` |
| **404 Not Found**             | No Orders for Table   | `{"error": "No orders found for table ID {table_id}."}` |
| **404 Not Found**             | No Orders in Database | `{"error": "No orders found in the database."}`         |
| **500 Internal Server Error** | Database Error        | `{"error": "C5INSERR"}`                                 |
| **500 Internal Server Error** | General Error         | `{"error": "C0INSERR: <error_message>"}`                |

---

### 6. Create Order

Creates a new order along with its order items.

- **Endpoint:** `/api/order/b{business_id}/`
- **Method:** `POST`
- **Authentication:** Not Required (JWT Token)
- **Request Body:**

```json
{
  "business_id": 1,
  "order_number": "ORD-001",
  "table_id": 3,
  "guest_id": 1,
  "order_type_id": 1,
  "status_id": 1,
  "subtotal": "500.00",
  "tax": "65.00",
  "discount": "0.00",
  "total_amount": "565.00",
  "notes": "Extra napkins",
  "served_by": null,
  "items": [
    {
      "food_item_id": 1,
      "quantity": 2,
      "status_id": 1,
      "note": "No onion"
    },
    {
      "food_item_id": 3,
      "quantity": 1,
      "status_id": 1
    }
  ]
}
```

#### Required Fields (Order)

| Field           | Type    | Description                   |
| :-------------- | :------ | :---------------------------- |
| `business_id`   | int     | Business ID                   |
| `order_number`  | string  | Unique order number           |
| `table_id`      | int     | Table ID                      |
| `guest_id`      | int     | Guest ID                      |
| `order_type_id` | int     | Order type (e.g. 1=Dining)    |
| `status_id`     | int     | Order status (e.g. 2=Pending) |
| `subtotal`      | decimal | Subtotal amount               |
| `total_amount`  | decimal | Final total                   |

#### Required Fields (each item in `items`)

| Field          | Type | Description      |
| :------------- | :--- | :--------------- |
| `food_item_id` | int  | Food item ID     |
| `quantity`     | int  | Quantity ordered |
| `status_id`    | int  | Item status ID   |

#### Optional Fields (item)

| Field  | Type   | Description          |
| :----- | :----- | :------------------- |
| `note` | string | Special instructions |

#### What happens on create

1. Validates all required fields and item availability
2. Creates the order record
3. Fetches prices from DB — `unit_price` from `food_item.price`, `total_price` = `unit_price × quantity`
4. Bulk-creates all order items (linked to the order + table)
5. Sets the table status to **occupied** (status 3)
6. Sends a WebSocket notification

#### Responses:

| Status Code                   | Scenario              | Body                                                                                      |
| :---------------------------- | :-------------------- | :---------------------------------------------------------------------------------------- |
| **201 Created**               | Success               | `{"message": "Order created successfully.", "order": {<order_object_with_items>}}`        |
| **400 Bad Request**           | Missing Fields        | `{"error": "Missing required fields: [...]"}`                                             |
| **400 Bad Request**           | Food Item Unavailable | `{"error": "<item_name> is currently unavailable.", "item_id": <id>, "available": false}` |
| **400 Bad Request**           | Validation Error      | `{<serializer_errors>}`                                                                   |
| **500 Internal Server Error** | Server Error          | `{"error": "C0INSERR: <error_message>"}`                                                  |

#### Success Response Example (201):

```json
{
  "message": "Order created successfully.",
  "order": {
    "id": 19,
    "business_id": 1,
    "business_name": "Haku",
    "order_number": "ORD-001",
    "table_id": "3",
    "guest_id": 1,
    "guest_name": "Sushil Shai",
    "order_type_id": 1,
    "order_type_name": "Dining",
    "status_id": 1,
    "status_name": "Complete",
    "subtotal": "500.00",
    "tax": "65.00",
    "discount": "0.00",
    "total_amount": "565.00",
    "notes": "Extra napkins",
    "served_by": null,
    "items": [
      {
        "id": 1,
        "order_id": 19,
        "table_id": 3,
        "food_item_id": 1,
        "food_item_name": "Momo",
        "quantity": 2,
        "unit_price": "150.00",
        "total_price": "300.00",
        "note": "No onion",
        "status_id": 1,
        "status_name": "Pending"
      },
      {
        "id": 2,
        "order_id": 19,
        "table_id": 3,
        "food_item_id": 3,
        "food_item_name": "Chowmein",
        "quantity": 1,
        "unit_price": "200.00",
        "total_price": "200.00",
        "note": "",
        "status_id": 1,
        "status_name": "Pending"
      }
    ],
    "created_at": "2026-02-26T12:00:00Z",
    "updated_at": "2026-02-26T12:00:00Z"
  }
}
```

---

## Staff Management APIs

### Staff Lookup Tables

The `role`, `shift`, and `status` fields accept integer IDs referencing their respective lookup tables.

**Staff Status:**

| ID  | Name     | Description                    |
| :-- | :------- | :----------------------------- |
| 1   | Active   | Staff member currently working |
| 2   | On_Leave | Staff member on leave          |
| 3   | Inactive | Staff member no longer active  |

> `role` and `shift` IDs are configured per-business in the database.

### Notes

- `password` is always **write-only** — it is never returned in any response.
- Passwords are hashed with PBKDF2 before storage.
- Phone numbers must be **unique per business**.
- There is currently **no dedicated change-password endpoint** for staff in `api/urls.py`; password can be updated via `PUT` on the staff detail endpoint.

---

### 7. Get Staff Members

Retrieves all staff members for a business, or a single staff member by ID.

- **Endpoint:** `/api/staff/b<business_id>/` or `/api/staff/b<business_id>/s<staff_id>/`
- **Method:** `GET`
- **Authentication:** Not Required (`AllowAny` in current view)
- **URL Parameters:**
  - `business_id` (required): Integer — Business ID
  - `staff_id` (optional): Integer — fetch a single staff member

#### Response (200 OK) — all staff for a business:

```json
{
  "staff": [
    {
      "id": 1,
      "business_id": 1,
      "business_name": "Hotel ABC",
      "role": 2,
      "role_name": "Receptionist",
      "shift": 1,
      "shift_name": "Morning",
      "status": 1,
      "status_name": "Active",
      "name": "John Smith",
      "phone": "9800000001",
      "created_at": "2026-01-10T09:00:00Z",
      "updated_at": "2026-01-10T09:00:00Z"
    }
  ]
}
```

#### Response (200 OK) — single staff member:

```json
{
  "staff": {
    "id": 1,
    "business_id": 1,
    "business_name": "Hotel ABC",
    "role": 2,
    "role_name": "Receptionist",
    "shift": 1,
    "shift_name": "Morning",
    "status": 1,
    "status_name": "Active",
    "name": "John Smith",
    "phone": "9800000001",
    "created_at": "2026-01-10T09:00:00Z",
    "updated_at": "2026-01-10T09:00:00Z"
  }
}
```

#### Responses:

| Status Code         | Scenario                 | Body                                                                                |
| :------------------ | :----------------------- | :---------------------------------------------------------------------------------- |
| **200 OK**          | Success                  | `{"staff": [...]}` or `{"staff": {...}}`                                            |
| **400 Bad Request** | Missing business context | `{"error": "business_id is required as a query parameter (?bid=) or in URL path."}` |
| **404 Not Found**   | Business not found       | `{"error": "Business with ID <business_id> does not exist."}`                       |
| **404 Not Found**   | Staff member not found   | `{"error": "Staff member not found."}`                                              |

---

### 8. Create Staff Member

Creates a new staff member under a business.

- **Endpoint:** `/api/staff/b<business_id>/`
- **Method:** `POST`
- **Authentication:** Not Required (`AllowAny` in current view)
- **Request Body:**

```json
{
  "role": 2,
  "shift": 1,
  "status": 1,
  "name": "Jane Doe",
  "phone": "9800000002",
  "password": "securepass123"
}
```

#### Validation Rules:

- Required fields: `role`, `shift`, `status`, `name`, `phone`, `password`
- `business_id` is taken from the URL path
- `business_id`, `role`, `shift`, and `status` must reference valid existing records
- Phone must be unique within the same business
- Password must be at least 8 characters

#### Response (201 Created):

```json
{
  "message": "Staff member created successfully.",
  "staff": {
    "id": 5,
    "business_id": 1,
    "business_name": "Hotel ABC",
    "role": 2,
    "role_name": "Receptionist",
    "shift": 1,
    "shift_name": "Morning",
    "status": 1,
    "status_name": "Active",
    "name": "Jane Doe",
    "phone": "9800000002",
    "created_at": "2026-02-27T10:00:00Z",
    "updated_at": "2026-02-27T10:00:00Z"
  }
}
```

#### Responses:

| Status Code         | Scenario                    | Body                                                                                  |
| :------------------ | :-------------------------- | :------------------------------------------------------------------------------------ |
| **201 Created**     | Success                     | `{"message": "Staff member created successfully.", "staff": {...}}`                   |
| **400 Bad Request** | Missing required field      | `{"error": "<field> is required."}`                                                   |
| **400 Bad Request** | Invalid `business_id`       | `{"error": "Invalid business_id."}`                                                   |
| **400 Bad Request** | Invalid `role`              | `{"error": "Invalid role."}`                                                          |
| **400 Bad Request** | Invalid `shift`             | `{"error": "Invalid shift."}`                                                         |
| **400 Bad Request** | Invalid `status`            | `{"error": "Invalid status."}`                                                        |
| **400 Bad Request** | Password too short          | `{"password": ["Password must be at least 8 characters."]}`                           |
| **409 Conflict**    | Duplicate phone in business | `{"error": "A staff member with this phone number already exists in this business."}` |

---

### 9. Update Staff Member

Partially updates a staff member. All fields are optional, including `password`.

- **Endpoint:** `/api/staff/b<business_id>/s<staff_id>/`
- **Method:** `PUT`
- **Authentication:** Not Required (`AllowAny` in current view)
- **URL Parameters:**
  - `business_id`: Integer (Required)
  - `staff_id`: Integer (Required)
- **Request Body (all fields optional):**

```json
{
  "shift": 2,
  "status": 2
}
```

#### Responses:

| Status Code         | Scenario                    | Body                                                                                          |
| :------------------ | :-------------------------- | :-------------------------------------------------------------------------------------------- |
| **200 OK**          | Success                     | `{"message": "Staff member updated successfully.", "staff": {...}}`                           |
| **400 Bad Request** | Missing `staff_id` in URL   | `{"error": "staff_id is required in URL."}`                                                   |
| **400 Bad Request** | Invalid FK value            | `{"error": "Invalid role."}` / `{"error": "Invalid shift."}` / `{"error": "Invalid status."}` |
| **400 Bad Request** | Validation error            | `{<serializer_errors>}`                                                                       |
| **404 Not Found**   | Staff member not found      | `{"error": "Staff member not found."}`                                                        |
| **409 Conflict**    | Duplicate phone in business | `{"error": "A staff member with this phone number already exists in this business."}`         |

---

### 10. Delete Staff Member

Permanently deletes a staff member.

- **Endpoint:** `/api/staff/b<business_id>/s<staff_id>/`
- **Method:** `DELETE`
- **Authentication:** Not Required (`AllowAny` in current view)
- **URL Parameters:**
  - `business_id`: Integer (Required)
  - `staff_id`: Integer (Required)

#### Responses:

| Status Code         | Scenario               | Body                                                |
| :------------------ | :--------------------- | :-------------------------------------------------- |
| **200 OK**          | Success                | `{"message": "Staff member deleted successfully."}` |
| **400 Bad Request** | Missing `staff_id`     | `{"error": "staff_id is required in URL."}`         |
| **404 Not Found**   | Staff member not found | `{"error": "Staff member not found."}`              |

---

## Guest Management APIs

### 11. Get Guests

Retrieves all guests or a specific guest.

- **Endpoint:** `/api/guests/` or `/api/guests/<guest_id>/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `guest_id` (optional): Integer - Get specific guest

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "business_id": 1,
    "name": "Alice Brown",
    "phone": "5551234567",
    "verify_id": 1,
    "status_id": 1,
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  }
]
```

#### Responses:

| Status Code          | Scenario         | Body                                      |
| :------------------- | :--------------- | :---------------------------------------- |
| **200 OK**           | Success          | `[<guest_objects>]` or `{<guest_object>}` |
| **404 Not Found**    | Guest Not Found  | `{"error": "Guest not found."}`           |
| **401 Unauthorized** | No/Invalid Token | Authentication error                      |

---

### 12. Create Guest

Creates a new guest.

- **Endpoint:** `/api/guests/`
- **Method:** `POST`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**

```json
{
  "business_id": 1,
  "name": "Bob Wilson",
  "phone": "5559876543",
  "verify_id": 1,
  "status_id": 1
}
```

#### Responses:

| Status Code         | Scenario            | Body                                                                    |
| :------------------ | :------------------ | :---------------------------------------------------------------------- |
| **201 Created**     | Success             | `{"message": "Guest created successfully.", "guest": {<guest_object>}}` |
| **400 Bad Request** | Missing Fields      | `{"error": "All fields are required."}`                                 |
| **400 Bad Request** | Invalid business_id | `{"error": "Invalid business_id."}`                                     |
| **400 Bad Request** | Invalid verify_id   | `{"error": "Invalid verify_id."}`                                       |
| **400 Bad Request** | Invalid status_id   | `{"error": "Invalid status_id."}`                                       |
| **400 Bad Request** | Validation Error    | `{<serializer_errors>}`                                                 |

---

### 13. Update Guest

Updates an existing guest's information.

- **Endpoint:** `/api/guests/<guest_id>/`
- **Method:** `PUT`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `guest_id`: Integer (Required) - Guest ID
- **Request Body (Partial Update Allowed):**

```json
{
  "name": "Bob Wilson Jr.",
  "status_id": 2
}
```

#### Responses:

| Status Code         | Scenario         | Body                                                                    |
| :------------------ | :--------------- | :---------------------------------------------------------------------- |
| **200 OK**          | Success          | `{"message": "Guest updated successfully.", "guest": {<guest_object>}}` |
| **400 Bad Request** | Missing guest_id | `{"error": "guest_id is required in URL."}`                             |
| **404 Not Found**   | Guest Not Found  | `{"error": "Guest not found."}`                                         |

---

### 14. Delete Guest

Deletes a guest.

- **Endpoint:** `/api/guests/<guest_id>/`
- **Method:** `DELETE`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `guest_id`: Integer (Required) - Guest ID

#### Responses:

| Status Code         | Scenario         | Body                                         |
| :------------------ | :--------------- | :------------------------------------------- |
| **200 OK**          | Success          | `{"message": "Guest deleted successfully."}` |
| **400 Bad Request** | Missing guest_id | `{"error": "guest_id is required in URL."}`  |
| **404 Not Found**   | Guest Not Found  | `{"error": "Guest not found."}`              |

---

## Category Management APIs

### 15. Get Food Categories

Retrieves all food categories for a specific business.

- **Endpoint:** `/api/menu_category/?bid=<business_id>`
- **Method:** `GET`
- **Authentication:** Not Required (AllowAny)
- **Query Parameters:**
  - `bid` (optional): Integer - Business ID (can be passed in URL path as well)

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "name": "Appetizers",
    "business_id": 1
  },
  {
    "id": 2,
    "name": "Main Course",
    "business_id": 1
  },
  {
    "id": 3,
    "name": "Desserts",
    "business_id": 1
  }
]
```

#### Responses:

| Status Code                   | Scenario            | Body                                     |
| :---------------------------- | :------------------ | :--------------------------------------- |
| **200 OK**                    | Success             | `[<category_objects>]`                   |
| **400 Bad Request**           | Missing business_id | `{"error": "Business ID is required."}`  |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`      |
| **500 Internal Server Error** | Server Error        | `{"error": "C0CATERR: <error_message>"}` |

---

### 16. Create Food Category

Creates a new food category for a specific business.

- **Endpoint:** `/api/menu_category/b<business_id>/`
- **Method:** `POST`
- **Authentication:** Not Required (AllowAny)
- **Request Body:**

```json
{
  "business_id": 1,
  "name": "Beverages"
}
```

**Required Fields:**

- `business_id`: Integer - The business ID the category belongs to
- `name`: String - The name of the category (e.g., "Appetizers", "Main Course")

#### Response (201 Created):

```json
{
  "message": "Category created successfully.",
  "category": {
    "id": 4,
    "name": "Beverages",
    "business_id": 1
  }
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                                               |
| :---------------------------- | :------------------ | :----------------------------------------------------------------- |
| **201 Created**               | Success             | `{"message": "Category created successfully.", "category": {...}}` |
| **400 Bad Request**           | Missing business_id | `{"error": "Business ID is required."}`                            |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`                                |
| **400 Bad Request**           | Missing name field  | `{"error": "name is required."}`                                   |
| **400 Bad Request**           | Validation Error    | `{<serializer_errors>}`                                            |
| **500 Internal Server Error** | Server Error        | `{"error": "C0CATERR: <error_message>"}`                           |

---

### 17. Update Food Category

Updates an existing food category.

- **Endpoint:** `/api/menu_category/b<business_id>/c<category_id>/`
- **Method:** `PUT`
- **Authentication:** Not Required (AllowAny)
- **URL Parameters:**
  - `business_id`: Integer (Required) - Business ID
  - `category_id`: Integer (Required) - Category ID to update
- **Request Body (Partial Update Allowed):**

```json
{
  "business_id": 1,
  "name": "Starters"
}
```

#### Response (200 OK):

```json
{
  "message": "Category updated successfully.",
  "category": {
    "id": 1,
    "name": "Starters",
    "business_id": 1
  }
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                                               |
| :---------------------------- | :------------------ | :----------------------------------------------------------------- |
| **200 OK**                    | Success             | `{"message": "Category updated successfully.", "category": {...}}` |
| **400 Bad Request**           | Missing business_id | `{"error": "Business ID is required."}`                            |
| **400 Bad Request**           | Missing category_id | `{"error": "Category ID is required."}`                            |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`                                |
| **400 Bad Request**           | Validation Error    | `{<serializer_errors>}`                                            |
| **404 Not Found**             | Category Not Found  | `{"error": "Category not found for the given business."}`          |
| **500 Internal Server Error** | Server Error        | `{"error": "C0CATERR: <error_message>"}`                           |

---

### 18. Delete Food Category

Deletes a food category from a business.

- **Endpoint:** `/api/menu_category/b<business_id>/c<category_id>/`
- **Method:** `DELETE`
- **Authentication:** Not Required (AllowAny)
- **URL Parameters:**
  - `business_id`: Integer (Required) - Business ID (can also be passed as `bid` query param)
  - `category_id`: Integer (Required) - Category ID to delete

#### Response (200 OK):

```json
{
  "message": "Category deleted successfully."
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                                      |
| :---------------------------- | :------------------ | :-------------------------------------------------------- |
| **200 OK**                    | Success             | `{"message": "Category deleted successfully."}`           |
| **400 Bad Request**           | Missing business_id | `{"error": "Business ID is required."}`                   |
| **400 Bad Request**           | Missing category_id | `{"error": "Category ID is required."}`                   |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`                       |
| **404 Not Found**             | Category Not Found  | `{"error": "Category not found for the given business."}` |
| **500 Internal Server Error** | Server Error        | `{"error": "C0CATERR: <error_message>"}`                  |

---

## Food Item Management APIs

### 19. Get Food Items

Retrieves all food items or a specific food item.

- **Endpoint:** `/api/menu/` or `/api/menu/<fooditem_id>/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `fooditem_id` (optional): Integer - Get specific food item

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "business_id": 1,
    "category_id": 2,
    "name": "Chicken Burger",
    "description": "Grilled chicken with fresh vegetables",
    "price": "12.99",
    "preparation_time": 15,
    "spice_level_id": 2,
    "is_available": true,
    "image_url": "https://example.com/burger.jpg",
    "created_at": "2024-01-01T08:00:00Z",
    "updated_at": "2024-01-01T08:00:00Z"
  }
]
```

#### Responses:

| Status Code          | Scenario            | Body                                              |
| :------------------- | :------------------ | :------------------------------------------------ |
| **200 OK**           | Success             | `[<food_item_objects>]` or `{<food_item_object>}` |
| **404 Not Found**    | Food Item Not Found | `{"error": "Food item not found."}`               |
| **401 Unauthorized** | No/Invalid Token    | Authentication error                              |

---

### 20. Create Food Item

Creates a new food item.

- **Endpoint:** `/api/fooditems/`
- **Method:** `POST`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**

```json
{
  "business_id": 1,
  "category_id": 2,
  "name": "Veggie Pizza",
  "description": "Fresh vegetables with mozzarella cheese",
  "price": "14.99",
  "preparation_time": 20,
  "spice_level_id": 1,
  "is_available": true,
  "image_url": "https://example.com/pizza.jpg"
}
```

**Note:** `spice_level_id`, `is_available`, and `image_url` are optional fields.

#### Responses:

| Status Code         | Scenario                | Body                                                                                |
| :------------------ | :---------------------- | :---------------------------------------------------------------------------------- |
| **201 Created**     | Success                 | `{"message": "Food item created successfully.", "food_item": {<food_item_object>}}` |
| **400 Bad Request** | Missing Required Fields | `{"error": "All fields are required."}`                                             |
| **400 Bad Request** | Invalid business_id     | `{"error": "Invalid business_id."}`                                                 |
| **400 Bad Request** | Invalid category_id     | `{"error": "Invalid category_id."}`                                                 |
| **400 Bad Request** | Invalid spice_level_id  | `{"error": "Invalid spice_level_id."}`                                              |
| **400 Bad Request** | Validation Error        | `{<serializer_errors>}`                                                             |

---

### 21. Update Food Item

Updates an existing food item.

- **Endpoint:** `/api/fooditems/<fooditem_id>/`
- **Method:** `PUT`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `fooditem_id`: Integer (Required) - Food item ID
- **Request Body (Partial Update Allowed):**

```json
{
  "price": "15.99",
  "is_available": false,
  "spice_level_id": 3
}
```

#### Responses:

| Status Code         | Scenario               | Body                                                                                |
| :------------------ | :--------------------- | :---------------------------------------------------------------------------------- |
| **200 OK**          | Success                | `{"message": "Food item updated successfully.", "food_item": {<food_item_object>}}` |
| **400 Bad Request** | Missing fooditem_id    | `{"error": "fooditem_id is required in URL."}`                                      |
| **400 Bad Request** | Invalid spice_level_id | `{"error": "Invalid spice_level_id."}`                                              |
| **404 Not Found**   | Food Item Not Found    | `{"error": "Food item not found."}`                                                 |

---

### 22. Delete Food Item

Deletes a food item.

- **Endpoint:** `/api/fooditems/<fooditem_id>/`
- **Method:** `DELETE`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `fooditem_id`: Integer (Required) - Food item ID

#### Responses:

| Status Code         | Scenario            | Body                                             |
| :------------------ | :------------------ | :----------------------------------------------- |
| **200 OK**          | Success             | `{"message": "Food item deleted successfully."}` |
| **400 Bad Request** | Missing pk          | `{"error": "pk is required in URL."}`            |
| **404 Not Found**   | Food Item Not Found | `{"error": "Food item not found."}`              |

---

## Order Item Management APIs

### 23. Get Order Items

Retrieves all order items or a specific order item.

- **Endpoint:** `/api/orderitems/` or `/api/orderitems/<order_item_id>/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `order_item_id` (optional): Integer - Get specific order item

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "order_id": 5,
    "food_item_id": 3,
    "quantity": 2,
    "unit_price": "12.99",
    "total_price": "25.98",
    "status_id": 1,
    "special_instructions": "Extra spicy",
    "created_at": "2024-01-01T12:15:00Z",
    "updated_at": "2024-01-01T12:15:00Z"
  }
]
```

#### Responses:

| Status Code          | Scenario             | Body                                                |
| :------------------- | :------------------- | :-------------------------------------------------- |
| **200 OK**           | Success              | `[<order_item_objects>]` or `{<order_item_object>}` |
| **404 Not Found**    | Order Item Not Found | `{"error": "Order item not found."}`                |
| **401 Unauthorized** | No/Invalid Token     | Authentication error                                |

---

### 24. Create Order Item

Creates a new order item (adds item to an order).

- **Endpoint:** `/api/orderitems/`
- **Method:** `POST`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**

```json
{
  "order_id": 5,
  "food_item_id": 3,
  "quantity": 2,
  "unit_price": "12.99",
  "total_price": "25.98",
  "status_id": 1,
  "special_instructions": "No onions"
}
```

**Note:** `special_instructions` is optional.

#### Responses:

| Status Code         | Scenario                | Body                                                                                   |
| :------------------ | :---------------------- | :------------------------------------------------------------------------------------- |
| **201 Created**     | Success                 | `{"message": "Order item created successfully.", "order_item": {<order_item_object>}}` |
| **400 Bad Request** | Missing Required Fields | `{"error": "All fields are required."}`                                                |
| **400 Bad Request** | Invalid order_id        | `{"error": "Invalid order_id."}`                                                       |
| **400 Bad Request** | Invalid food_item_id    | `{"error": "Invalid food_item_id."}`                                                   |
| **400 Bad Request** | Invalid status_id       | `{"error": "Invalid status_id."}`                                                      |
| **400 Bad Request** | Validation Error        | `{<serializer_errors>}`                                                                |

---

### 25. Update Order Item

Updates an existing order item.

- **Endpoint:** `/api/orderitems/<order_item_id>/`
- **Method:** `PUT`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `order_item_id`: Integer (Required) - Order item ID
- **Request Body (Partial Update Allowed):**

```json
{
  "quantity": 3,
  "total_price": "38.97",
  "status_id": 2
}
```

#### Responses:

| Status Code         | Scenario              | Body                                                                                   |
| :------------------ | :-------------------- | :------------------------------------------------------------------------------------- |
| **200 OK**          | Success               | `{"message": "Order item updated successfully.", "order_item": {<order_item_object>}}` |
| **400 Bad Request** | Missing order_item_id | `{"error": "order_item_id is required in URL."}`                                       |
| **404 Not Found**   | Order Item Not Found  | `{"error": "Order item not found."}`                                                   |

---

### 26. Delete Order Item

Deletes an order item.

- **Endpoint:** `/api/orderitems/<order_item_id>/`
- **Method:** `DELETE`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `order_item_id`: Integer (Required) - Order item ID

#### Responses:

| Status Code         | Scenario              | Body                                              |
| :------------------ | :-------------------- | :------------------------------------------------ |
| **200 OK**          | Success               | `{"message": "Order item deleted successfully."}` |
| **400 Bad Request** | Missing order_item_id | `{"error": "order_item_id is required in URL."}`  |
| **404 Not Found**   | Order Item Not Found  | `{"error": "Order item not found."}`              |

---

## Table Management APIs

### 27. Get Tables

Retrieves all tables or a specific table.

- **Endpoint:** `/api/tables/` or `/api/tables/<table_id>/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **URL Parameters:**
  - `table_id` (optional): Integer - Get specific table

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "business_id": 1,
    "table_number": "T-01",
    "location": "Main Hall",
    "status_id": 1,
    "reserved_by": null,
    "created_at": "2024-01-01T07:00:00Z",
    "updated_at": "2024-01-01T07:00:00Z"
  }
]
```

#### Responses:

| Status Code       | Scenario        | Body                                      |
| :---------------- | :-------------- | :---------------------------------------- |
| **200 OK**        | Success         | `[<table_objects>]` or `{<table_object>}` |
| **404 Not Found** | Table Not Found | `{"error": "Table not found."}`           |

---

### 28. Create Table

Creates a new table.

- **Endpoint:** `/api/tables/`
- **Method:** `POST`
- **Authentication:** Required (JWT Token)
- **Request Body:**

```json
{
  "business_id": 1,
  "table_number": "T-05",
  "capacity": 6,
  "location": "Garden Area",
  "status_id": 1,
  "reserved_by": null
}
```

**Note:** `capacity`, `reserved_by`, and `qr_code` are optional fields.

#### Responses:

| Status Code         | Scenario                | Body                                                                    |
| :------------------ | :---------------------- | :---------------------------------------------------------------------- |
| **201 Created**     | Success                 | `{"message": "Table created successfully.", "table": {<table_object>}}` |
| **400 Bad Request** | Missing Required Fields | `{"error": "All fields are required."}`                                 |
| **400 Bad Request** | Invalid business_id     | `{"error": "Invalid business_id."}`                                     |
| **400 Bad Request** | Invalid status_id       | `{"error": "Invalid status_id."}`                                       |
| **400 Bad Request** | Invalid reserved_by     | `{"error": "Invalid reserved_by ID."}`                                  |
| **400 Bad Request** | Validation Error        | `{<serializer_errors>}`                                                 |

---

### 29. Update Table

Updates an existing table.

- **Endpoint:** `/api/tables/<table_id>/`
- **Method:** `PUT`
- **Authentication:** Not Required (JWT Token)
- **URL Parameters:**
  - `table_id`: Integer (Required) - Table ID
- **Request Body (Partial Update Allowed):**

```json
{
  "status_id": 2,
  "reserved_by": 5
}
```

#### Responses:

| Status Code         | Scenario         | Body                                                                    |
| :------------------ | :--------------- | :---------------------------------------------------------------------- |
| **200 OK**          | Success          | `{"message": "Table updated successfully.", "table": {<table_object>}}` |
| **400 Bad Request** | Missing table_id | `{"error": "table_id is required in URL."}`                             |
| **404 Not Found**   | Table Not Found  | `{"error": "Table not found."}`                                         |

---

### 30. Delete Table

Deletes a table.

- **Endpoint:** `/api/tables/<table_id>/`
- **Method:** `DELETE`
- **Authentication:** Not Required (JWT Token)
- **URL Parameters:**
  - `table_id`: Integer (Required) - Table ID

#### Responses:

| Status Code         | Scenario         | Body                                         |
| :------------------ | :--------------- | :------------------------------------------- |
| **200 OK**          | Success          | `{"message": "Table deleted successfully."}` |
| **400 Bad Request** | Missing table_id | `{"error": "table_id is required in URL."}`  |
| **404 Not Found**   | Table Not Found  | `{"error": "Table not found."}`              |

---

## Booking Management APIs

### Booking Status Reference

All booking status IDs are fixed in the database. The system uses these IDs to drive business logic (overlap checks, room status transitions, amount calculation).

| ID  | Name        | Description                                     |
| :-- | :---------- | :---------------------------------------------- |
| 1   | Checked_in  | Guest has physically checked in to the room     |
| 2   | Checked_out | Guest has checked out                           |
| 3   | Booked      | Reservation confirmed, guest not yet arrived    |
| 5   | Cancelled   | Booking cancelled; room becomes available again |

### Automatic Calculations on Booking Creation

| Field       | How it is computed                                           | Writable by client |
| :---------- | :----------------------------------------------------------- | :----------------- |
| `nights`    | `(check_out - check_in).days` — set by the model on `save()` | No (read-only)     |
| `amount`    | `room.price × nights` — set by the service before saving     | No (auto-computed) |
| `status_id` | Always forced to `3` (Booked) on creation                    | No (ignored)       |

### Automatic Room Status Transitions

When `status_id` is updated via `PUT /api/booking/b<business_id>/bk<booking_id>/`, the linked room's status is updated automatically:

| Booking status set to | Room status becomes |
| :-------------------- | :------------------ |
| `1` — Checked_in      | `Occupied`          |
| `2` — Checked_out     | `Maintenance`       |
| Any other value       | No change           |

This transition is **best-effort** — the booking update is always saved even if the room status update fails.

---

### 31. Get Bookings

Retrieves all bookings or a specific booking.

- **Endpoint:** `/api/booking/b<business_id>/` or `/api/booking/b<business_id>/bk<booking_id>/`
- **Method:** `GET`
- **Authentication:** Not Required (`AllowAny` in current view)
- **URL Parameters:**
  - `business_id` (required): Integer — filter by business
  - `booking_id` (optional): Integer — fetch a single booking by ID

#### Response (200 OK) — all bookings:

```json
{
  "bookings": [
    {
      "id": 1,
      "business_id": 1,
      "business_name": "Hotel ABC",
      "room_id": 5,
      "room_number": "101",
      "room_number_display": "101",
      "guest_id": 3,
      "guest_name": "John Doe",
      "guest_phone": "9800000000",
      "check_in": "2026-02-15T14:00:00Z",
      "check_out": "2026-02-18T11:00:00Z",
      "nights": 3,
      "amount": "45000.00",
      "status_id": 3,
      "status_name": "Booked",
      "advance_payment": "5000.00",
      "advance_date": "2026-02-10T09:00:00Z",
      "advance_payment_method": 1,
      "payment_method_name": "Cash",
      "created_at": "2026-02-10T09:00:00Z",
      "updated_at": "2026-02-10T09:00:00Z"
    }
  ]
}
```

#### Response (200 OK) — single booking:

```json
{
  "booking": {
    "id": 1,
    "business_id": 1,
    "business_name": "Hotel ABC",
    "room_id": 5,
    "room_number": "101",
    "room_number_display": "101",
    "guest_id": 3,
    "guest_name": "John Doe",
    "guest_phone": "9800000000",
    "check_in": "2026-02-15T14:00:00Z",
    "check_out": "2026-02-18T11:00:00Z",
    "nights": 3,
    "amount": "45000.00",
    "status_id": 3,
    "status_name": "Booked",
    "advance_payment": "5000.00",
    "advance_date": "2026-02-10T09:00:00Z",
    "advance_payment_method": 1,
    "payment_method_name": "Cash",
    "created_at": "2026-02-10T09:00:00Z",
    "updated_at": "2026-02-10T09:00:00Z"
  }
}
```

#### Responses:

| Status Code                   | Scenario          | Body                                                                  |
| :---------------------------- | :---------------- | :-------------------------------------------------------------------- |
| **200 OK**                    | Success           | `{"bookings": [...]}` or `{"booking": {...}}`                         |
| **400 Bad Request**           | Invalid business  | `{"error": "Invalid business_id."}`                                   |
| **400 Bad Request**           | Missing business  | `{"error": "business_id is required in URL."}`                        |
| **404 Not Found**             | Booking not found | `{"error": "Booking with ID <id> does not exist for this business."}` |
| **500 Internal Server Error** | Server error      | `{"error": "C0INSERR - Internal server error"}`                       |

---

### 32. Create Booking

Creates a new booking. `nights` and `amount` are **computed automatically** by the server — do not send them. The booking is always created with status `Booked` (ID 3). Room availability is validated atomically to prevent double-booking.

> **Note:** Do not pass `status_id`, `nights`, or `amount` — all are ignored/overwritten by the server.
> number": "101",
> "guest_name": "John Doe",
> "guest_phone": "9876543210",
> "check_in": "2026-02-15T14:00:00Z",
> "check_out": "2026-02-18T11:00:00Z",
> "advance_payment": 5000.00,
> "advance_date": "2026-02-10T09:00:00Z",
> "advance_payment_method": 1
> }

```

#### Validation Rules:

- Required request fields: `room_number`, `guest_name`, `check_in`, `check_out`, `advance_payment`, `advance_date`, `advance_payment_method`
- Optional request fields: `guest_phone`
- `business_id` is taken from the URL path
- `room_number` must belong to the given `business_id`
- `guest_name` is used to find an existing guest or create a new one automatically
}
```

#### Validation Rules:

- Required request fields: `room_id`, `guest_id`, `check_in`, `check_out`
- `business_id` is taken from the URL path
- `room_id` must belong to the given `business_id`
- Dates must be valid ISO 8601 strings
- `check_in` must be in the future
- `check_out` must be after `check_in`
- Booking duration cannot exceed 365 days
- The room must have no overlapping active (non-cancelled) bookings for the requested period

#### Response (201 Created):

```json
{
  "message": "Booking created successfully.",
  "booking": {
    "id": 7,
    "business_id": 1,
    "business_name": "Hotel ABC",
    "room_id": 5,
    "room_number": "101",
    "room_number_display": "101",
    "guest_id": 3,
    "guest_name": "John Doe",
    "guest_phone": "9800000000",
    "check_in": "2026-02-15T14:00:00Z",
    "check_out": "2026-02-18T11:00:00Z",
    "nights": 3,
    "amount": "45000.00",
    "status_id": 3,
    "status_name": "Booked",
    "advance_payment": "5000.00",
    "advance_date": "2026-02-10T09:00:00Z",
    "advance_payment_method": 1,
    "payment_method_name": "Cash",
    "created_at": "2026-02-15T08:00:00Z",
    "updated_at": "2026-02-15T08:00:00Z"
  },
  "status": "booked"
}
```

#### Responses:

| Status Code                   | Scenario                      | Body                                                                                                          |
| :---------------------------- | :---------------------------- | :------------------------------------------------------------------------------------------------------------ |
| **201 Created**               | Success                       | `{"message": "Booking created successfully.", "booking": {...}, "status": "booked"}`                          |
| **400 Bad Request**           | Missing required field        | `{"error": "<field> is required."}`                                                                           |
| **400 Bad Request**           | Missing business in URL       | `{"error": "business_id is required in URL."}`                                                                |
| **400 Bad Request**           | Invalid `business_id`         | `{"error": "Invalid business_id."}`                                                                           |
| **400 Bad Request**           | Invalid `guest_id`            | `{"error": "Invalid guest_id."}`                                                                              |
| **400 Bad Request**           | Room not in business          | `{"error": "Invalid room_id or room does not belong to this business."}`                                      |
| **400 Bad Request**           | Bad date format               | `{"error": "Invalid date format. Use ISO 8601 (e.g. 2025-06-01T14:00:00Z)."}`                                 |
| **400 Bad Request**           | `check_out` before `check_in` | `{"error": "check_out must be after check_in."}`                                                              |
| **400 Bad Request**           | `check_in` in the past        | `{"error": "check_in must be in the future."}`                                                                |
| **400 Bad Request**           | Duration exceeds 365 days     | `{"error": "Booking duration cannot exceed 365 days."}`                                                       |
| **409 Conflict**              | Room already booked           | `{"error": "Room not available.", "message": "The selected room is already booked for the specified dates."}` |
| **500 Internal Server Error** | Server error                  | `{"error": "C0INSERR: <error_message>"}`                                                                      |

---

### 33. Update Booking (Status Transition)

Updates an existing booking. Updating `status_id` triggers automatic room status transitions (see table above). All fields are optional (partial update).

- **Endpoint:** `/api/booking/b<business_id>/bk<booking_id>/`
- **Method:** `PUT`
- **Authentication:** Not Required (`AllowAny` in current view)
- **URL Parameters:**
  - `business_id`: Integer (Required)
  - `booking_id`: Integer (Required)
- **Request Body (all fields optional):**

```json
{
  "status_id": 1,
  "advance_payment": "6000.00",
  "advance_payment_method": 2
}
```

#### Booking Lifecycle:

```
POST /booking/b1/         → status_id: 3  (Booked)        room: no change
                           nights & amount auto-set
PUT  /booking/b1/bk7/     → status_id: 1  (Checked_in)    room: → Occupied
PUT  /booking/b1/bk7/     → status_id: 2  (Checked_out)   room: → Maintenance
PUT  /booking/b1/bk7/     → status_id: 5  (Cancelled)     room: no change
```

#### Response (200 OK):

```json
{
  "message": "Booking updated successfully.",
  "booking": {
    "id": 7,
    "business_id": 1,
    "business_name": "Hotel ABC",
    "room_id": 5,
    "room_number": "101",
    "guest_id": 3,
    "guest_name": "John Doe",
    "check_in": "2026-02-15T14:00:00Z",
    "check_out": "2026-02-18T11:00:00Z",
    "nights": 3,
    "amount": "45000.00",
    "status_id": 1,
    "status_name": "Checked_in",
    "created_at": "2026-02-15T08:00:00Z",
    "updated_at": "2026-02-15T14:05:00Z"
  }
}
```

#### Responses:

| Status Code                   | Scenario             | Body                                                                          |
| :---------------------------- | :------------------- | :---------------------------------------------------------------------------- |
| **200 OK**                    | Success              | `{"message": "Booking updated successfully.", "booking": {<booking_object>}}` |
| **400 Bad Request**           | Missing `booking_id` | `{"error": "booking_id is required in URL."}`                                 |
| **400 Bad Request**           | Validation error     | `{<serializer_errors>}`                                                       |
| **404 Not Found**             | Booking not found    | `{"error": "Booking not found."}`                                             |
| **500 Internal Server Error** | Server error         | `{"error": "C0INSERR: <error_message>"}`                                      |

---

### 34. Delete Booking

Permanently deletes a booking record.

- **Endpoint:** `/api/booking/b<business_id>/bk<booking_id>/`
- **Method:** `DELETE`
- **Authentication:** Not Required (`AllowAny` in current view)
- **URL Parameters:**
  - `business_id`: Integer (Required)
  - `booking_id`: Integer (Required)

> **Tip:** Prefer setting `status_id: 5` (Cancelled) via `PUT` instead of hard-deleting, to retain booking history.

#### Responses:

| Status Code                   | Scenario             | Body                                           |
| :---------------------------- | :------------------- | :--------------------------------------------- |
| **200 OK**                    | Success              | `{"message": "Booking deleted successfully."}` |
| **400 Bad Request**           | Missing `booking_id` | `{"error": "booking_id is required in URL."}`  |
| **404 Not Found**             | Booking not found    | `{"error": "Booking not found."}`              |
| **500 Internal Server Error** | Server error         | `{"error": "C0INSERR: <error_message>"}`       |

---

## Room Management APIs

### 35. Get Rooms

Retrieves all rooms or a specific room.

- **Endpoint:** `/api/rooms/` or `/api/rooms/<room_id>/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `room_id` (optional): Integer - Get specific room

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "business_id": 1,
    "business_name": "Hotel ABC",
    "room_number": "101",
    "type_id": 2,
    "room_type_name": "Deluxe",
    "capacity": 2,
    "price": "5000.00",
    "floor": 1,
    "status_id": 1,
    "status_name": "Available",
    "created_at": "2026-01-01T10:00:00Z",
    "updated_at": "2026-01-01T10:00:00Z"
  }
]
```

#### Responses:

| Status Code                   | Scenario         | Body                                     |
| :---------------------------- | :--------------- | :--------------------------------------- |
| **200 OK**                    | Success          | `[<room_objects>]` or `{<room_object>}`  |
| **404 Not Found**             | Room Not Found   | `{"error": "Room not found."}`           |
| **401 Unauthorized**          | No/Invalid Token | Authentication error                     |
| **500 Internal Server Error** | Server Error     | `{"error": "C0INSERR: <error_message>"}` |

---

### 36. Create Room

Creates a new room.

- **Endpoint:** `/api/rooms/`
- **Method:** `POST`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**

```json
{
  "business_id": 1,
  "room_number": "102",
  "type_id": 2,
  "capacity": 3,
  "price": "7500.00",
  "floor": 1,
  "status_id": 1
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                                                 |
| :---------------------------- | :------------------ | :------------------------------------------------------------------- |
| **201 Created**               | Success             | `{"message": "Room created successfully.", "room": {<room_object>}}` |
| **400 Bad Request**           | Missing Fields      | `{"error": "All fields are required."}`                              |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`                                  |
| **400 Bad Request**           | Validation Error    | `{<serializer_errors>}`                                              |
| **500 Internal Server Error** | Server Error        | `{"error": "C0INSERR: <error_message>"}`                             |

---

### 37. Update Room

Updates an existing room.

- **Endpoint:** `/api/rooms/<room_id>/`
- **Method:** `PUT`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `room_id`: Integer (Required) - Room ID
- **Request Body (Partial Update Allowed):**

```json
{
  "price": "8000.00",
  "status_id": 2
}
```

#### Responses:

| Status Code                   | Scenario         | Body                                                                 |
| :---------------------------- | :--------------- | :------------------------------------------------------------------- |
| **200 OK**                    | Success          | `{"message": "Room updated successfully.", "room": {<room_object>}}` |
| **400 Bad Request**           | Missing room_id  | `{"error": "Room ID is required."}`                                  |
| **400 Bad Request**           | Validation Error | `{<serializer_errors>}`                                              |
| **404 Not Found**             | Room Not Found   | `{"error": "Room not found."}`                                       |
| **500 Internal Server Error** | Server Error     | `{"error": "C0UPDERR: <error_message>"}`                             |

---

### 38. Delete Room

Deletes a room.

- **Endpoint:** `/api/rooms/<room_id>/`
- **Method:** `DELETE`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `room_id`: Integer (Required) - Room ID

#### Responses:

| Status Code                   | Scenario        | Body                                        |
| :---------------------------- | :-------------- | :------------------------------------------ |
| **200 OK**                    | Success         | `{"message": "Room deleted successfully."}` |
| **400 Bad Request**           | Missing room_id | `{"error": "Room ID is required."}`         |
| **404 Not Found**             | Room Not Found  | `{"error": "Room not found."}`              |
| **500 Internal Server Error** | Server Error    | `{"error": "C0DELERR: <error_message>"}`    |

---

## Invoice Management APIs

### 39. Get Invoices

Retrieves all invoices or a specific invoice.

- **Endpoint:** `/api/invoice/` or `/api/invoice/<invoice_id>/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `invoice_id` (optional): Integer - Get specific invoice

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "business_id": 1,
    "business_name": "Hotel ABC",
    "booking_id": 5,
    "guest_id": 3,
    "guest_name": "John Doe",
    "room_id": 10,
    "check_in": "2026-02-15T14:00:00Z",
    "check_out": "2026-02-18T11:00:00Z",
    "nights": 3,
    "room_charges": "15000.00",
    "discount": "500.00",
    "additional_charges": "1500.00",
    "total_amount": "16000.00",
    "paid_amount": "10000.00",
    "due_amount": "6000.00",
    "status_id": 1,
    "status_name": "Pending",
    "invoice_date": "2026-02-18T11:30:00Z",
    "created_at": "2026-02-18T11:30:00Z",
    "updated_at": "2026-02-18T11:30:00Z"
  }
]
```

#### Responses:

| Status Code                   | Scenario          | Body                                          |
| :---------------------------- | :---------------- | :-------------------------------------------- |
| **200 OK**                    | Success           | `[<invoice_objects>]` or `{<invoice_object>}` |
| **404 Not Found**             | Invoice Not Found | `{"error": "Invoice not found."}`             |
| **401 Unauthorized**          | No/Invalid Token  | Authentication error                          |
| **500 Internal Server Error** | Server Error      | `{"error": "C0INSERR: <error_message>"}`      |

---

### 40. Create Invoice

Creates a new invoice.

- **Endpoint:** `/api/invoice/`
- **Method:** `POST`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**

```json
{
  "business_id": 1,
  "invoice_number": "INV-2026-001",
  "guest_id": 3,
  "status_id": 1,
  "amount": "16000.00"
}
```

#### Responses:

| Status Code                   | Scenario                 | Body                                                                          |
| :---------------------------- | :----------------------- | :---------------------------------------------------------------------------- |
| **201 Created**               | Success                  | `{"message": "Invoice created successfully.", "invoice": {<invoice_object>}}` |
| **400 Bad Request**           | Missing Fields           | `{"error": "All fields are required."}`                                       |
| **400 Bad Request**           | Invalid business_id      | `{"error": "Invalid business_id."}`                                           |
| **400 Bad Request**           | Invalid guest_id         | `{"error": "Invalid guest_id."}`                                              |
| **400 Bad Request**           | Invalid status_id        | `{"error": "Invalid status_id."}`                                             |
| **400 Bad Request**           | Invalid invoice_number   | `{"error": "Invalid invoice_number."}`                                        |
| **400 Bad Request**           | Duplicate Invoice Number | `{"error": "Duplicate invoice_number found."}`                                |
| **500 Internal Server Error** | Server Error             | `{"error": "C0INSERR: <error_message>"}`                                      |

---

### 41. Update Invoice

Updates an existing invoice.

- **Endpoint:** `/api/invoice/<invoice_id>/`
- **Method:** `PUT`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `invoice_id`: Integer (Required) - Invoice ID
- **Request Body (Partial Update Allowed):**

```json
{
  "paid_amount": "16000.00",
  "due_amount": "0.00",
  "status_id": 2
}
```

#### Responses:

| Status Code                   | Scenario           | Body                                                                          |
| :---------------------------- | :----------------- | :---------------------------------------------------------------------------- |
| **200 OK**                    | Success            | `{"message": "Invoice updated successfully.", "invoice": {<invoice_object>}}` |
| **400 Bad Request**           | Missing invoice_id | `{"error": "Invoice ID is required."}`                                        |
| **400 Bad Request**           | Validation Error   | `{<serializer_errors>}`                                                       |
| **404 Not Found**             | Invoice Not Found  | `{"error": "Invoice not found."}`                                             |
| **500 Internal Server Error** | Server Error       | `{"error": "C0UPDERR: <error_message>"}`                                      |

---

### 42. Delete Invoice

Deletes an invoice.

- **Endpoint:** `/api/invoice/<invoice_id>/`
- **Method:** `DELETE`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `invoice_id`: Integer (Required) - Invoice ID

#### Responses:

| Status Code                   | Scenario           | Body                                           |
| :---------------------------- | :----------------- | :--------------------------------------------- |
| **200 OK**                    | Success            | `{"message": "Invoice deleted successfully."}` |
| **400 Bad Request**           | Missing invoice_id | `{"error": "Invoice ID is required."}`         |
| **404 Not Found**             | Invoice Not Found  | `{"error": "Invoice not found."}`              |
| **500 Internal Server Error** | Server Error       | `{"error": "C0DELERR: <error_message>"}`       |

---

## Payment Management APIs

### 43. Get Payments

Retrieves all payments or a specific payment.

- **Endpoint:** `/api/payment/` or `/api/payment/<payment_id>/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `payment_id` (optional): Integer - Get specific payment

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "booking_id": 5,
    "method_id": 1,
    "amount": "10000.00",
    "paid_at": "2026-02-18T12:00:00Z",
    "status_id": 1,
    "is_advance": false,
    "created_at": "2026-02-18T12:00:00Z",
    "updated_at": "2026-02-18T12:00:00Z"
  }
]
```

#### Responses:

| Status Code                   | Scenario          | Body                                          |
| :---------------------------- | :---------------- | :-------------------------------------------- |
| **200 OK**                    | Success           | `[<payment_objects>]` or `{<payment_object>}` |
| **404 Not Found**             | Payment Not Found | `{"error": "Payment not found."}`             |
| **401 Unauthorized**          | No/Invalid Token  | Authentication error                          |
| **500 Internal Server Error** | Server Error      | `{"error": "C0PAYERR: <error_message>"}`      |

---

### 44. Create Payment

Records a new payment.

- **Endpoint:** `/api/payment/`
- **Method:** `POST`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**

```json
{
  "business_id": 1,
  "guest_id": 3,
  "amount": "10000.00",
  "payment_method": "Cash",
  "payment_date": "2026-02-18T12:00:00Z"
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                                                           |
| :---------------------------- | :------------------ | :----------------------------------------------------------------------------- |
| **201 Created**               | Success             | `{"message": "Payment recorded successfully.", "payment": {<payment_object>}}` |
| **400 Bad Request**           | Missing Fields      | `{"error": "All fields are required."}`                                        |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`                                            |
| **400 Bad Request**           | Invalid guest_id    | `{"error": "Invalid guest_id."}`                                               |
| **400 Bad Request**           | Validation Error    | `{<serializer_errors>}`                                                        |
| **500 Internal Server Error** | Server Error        | `{"error": "C0PAYERR: <error_message>"}`                                       |

---

### 45. Update Payment

Updates an existing payment record.

- **Endpoint:** `/api/payment/<payment_id>/`
- **Method:** `PUT`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `payment_id`: Integer (Required) - Payment ID
- **Request Body (Partial Update Allowed):**

```json
{
  "amount": "12000.00",
  "status_id": 2
}
```

#### Responses:

| Status Code                   | Scenario           | Body                                                                          |
| :---------------------------- | :----------------- | :---------------------------------------------------------------------------- |
| **200 OK**                    | Success            | `{"message": "Payment updated successfully.", "payment": {<payment_object>}}` |
| **400 Bad Request**           | Missing payment_id | `{"error": "Payment ID is required."}`                                        |
| **400 Bad Request**           | Validation Error   | `{<serializer_errors>}`                                                       |
| **404 Not Found**             | Payment Not Found  | `{"error": "Payment not found."}`                                             |
| **500 Internal Server Error** | Server Error       | `{"error": "C0PAYERR: <error_message>"}`                                      |

---

### 46. Delete Payment

Deletes a payment record.

- **Endpoint:** `/api/payment/<payment_id>/`
- **Method:** `DELETE`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **URL Parameters:**
  - `payment_id`: Integer (Required) - Payment ID

#### Responses:

| Status Code                   | Scenario           | Body                                           |
| :---------------------------- | :----------------- | :--------------------------------------------- |
| **200 OK**                    | Success            | `{"message": "Payment deleted successfully."}` |
| **400 Bad Request**           | Missing payment_id | `{"error": "Payment ID is required."}`         |
| **404 Not Found**             | Payment Not Found  | `{"error": "Payment not found."}`              |
| **500 Internal Server Error** | Server Error       | `{"error": "C0PAYERR: <error_message>"}`       |

---

## Dashboard APIs

### 47. Room Status Overview

Retrieves room status statistics for a business (Admin Dashboard).

- **Endpoint:** `/api/room-status/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Query Parameters:**
  - `bid`: Integer (Required) - Business ID

#### Response (200 OK):

```json
{
  "business_id": "1",
  "room_status": {
    "total": 50,
    "available": 25,
    "occupied": 20,
    "maintenance": 5,
    "checked_in": 8
  }
}
```

**Note:** `checked_in` shows count of check-ins in the last 24 hours.

#### Responses:

| Status Code                   | Scenario            | Body                                           |
| :---------------------------- | :------------------ | :--------------------------------------------- |
| **200 OK**                    | Success             | `{"business_id": "...", "room_status": {...}}` |
| **400 Bad Request**           | Missing bid         | `{"error": "Business ID is required."}`        |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`            |
| **500 Internal Server Error** | Server Error        | `{"error": "C0STATERR: <error_message>"}`      |

---

### 48. Get Check-Ins (Last 24 Hours)

Retrieves all bookings with check-in status from the last 24 hours.

- **Endpoint:** `/api/check-in/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Query Parameters:**
  - `bid`: Integer (Required) - Business ID

#### Response (200 OK):

```json
{
  "check_in_bookings": [
    {
      "id": 1,
      "business_id": 1,
      "guest_id": 3,
      "guest_name": "John Doe",
      "room_id": 5,
      "room_number": "101",
      "check_in": "2026-02-12T14:00:00Z",
      "check_out": "2026-02-15T11:00:00Z",
      "status_id": 2
    }
  ]
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                         |
| :---------------------------- | :------------------ | :------------------------------------------- |
| **200 OK**                    | Success             | `{"check_in_bookings": [<booking_objects>]}` |
| **400 Bad Request**           | Missing bid         | `{"error": "Business ID is required."}`      |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`          |
| **500 Internal Server Error** | Server Error        | `{"error": "C0CHKINERR: <error_message>"}`   |

---

### 49. Get Check-Outs (Last 24 Hours)

Retrieves all bookings with check-out status from the last 24 hours.

- **Endpoint:** `/api/check-out/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Query Parameters:**
  - `bid`: Integer (Required) - Business ID

#### Response (200 OK):

```json
{
  "check_out_bookings": [
    {
      "id": 2,
      "business_id": 1,
      "guest_id": 4,
      "guest_name": "Jane Smith",
      "room_id": 10,
      "room_number": "205",
      "check_in": "2026-02-09T14:00:00Z",
      "check_out": "2026-02-12T11:00:00Z",
      "status_id": 3
    }
  ]
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                          |
| :---------------------------- | :------------------ | :-------------------------------------------- |
| **200 OK**                    | Success             | `{"check_out_bookings": [<booking_objects>]}` |
| **400 Bad Request**           | Missing bid         | `{"error": "Business ID is required."}`       |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`           |
| **500 Internal Server Error** | Server Error        | `{"error": "C0CHKINERR: <error_message>"}`    |

---

### 50. Get Booked Rooms

Retrieves all current bookings with "Booked" status.

- **Endpoint:** `/api/booked/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Query Parameters:**
  - `bid`: Integer (Required) - Business ID

#### Response (200 OK):

```json
{
  "booked": [
    {
      "id": 3,
      "business_id": 1,
      "guest_id": 5,
      "guest_name": "Bob Wilson",
      "room_id": 15,
      "room_number": "301",
      "check_in": "2026-02-20T14:00:00Z",
      "check_out": "2026-02-25T11:00:00Z",
      "status_id": 1
    }
  ]
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                       |
| :---------------------------- | :------------------ | :----------------------------------------- |
| **200 OK**                    | Success             | `{"booked": [<booking_objects>]}`          |
| **400 Bad Request**           | Missing bid         | `{"error": "Business ID is required."}`    |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`        |
| **500 Internal Server Error** | Server Error        | `{"error": "C0CHKINERR: <error_message>"}` |

---

### 51. Menu Status Overview

Retrieves menu/food item statistics for a business (Admin Dashboard).

- **Endpoint:** `/api/menu/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Query Parameters:**
  - `bid`: Integer (Required) - Business ID

#### Response (200 OK):

```json
{
  "business_id": "1",
  "menu_status": {
    "total_food_items": 50,
    "available_food_items": 45,
    "total_categories": 8
  }
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                           |
| :---------------------------- | :------------------ | :--------------------------------------------- |
| **200 OK**                    | Success             | `{"business_id": "...", "menu_status": {...}}` |
| **400 Bad Request**           | Missing bid         | `{"error": "Business ID is required."}`        |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`            |
| **500 Internal Server Error** | Server Error        | `{"error": "C0MENUERR: <error_message>"}`      |

---

### 52. Staff Status Overview

Retrieves staff statistics for a business (Admin Dashboard).

- **Endpoint:** `/api/staff-status/`
- **Method:** `GET`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`
- **Query Parameters:**
  - `bid`: Integer (Required) - Business ID

#### Response (200 OK):

```json
{
  "business_id": "1",
  "staff_status": {
    "total_staff_count": 25,
    "active_staff_count": 20,
    "on_leave_count": 5
  }
}
```

#### Responses:

| Status Code                   | Scenario            | Body                                            |
| :---------------------------- | :------------------ | :---------------------------------------------- |
| **200 OK**                    | Success             | `{"business_id": "...", "staff_status": {...}}` |
| **400 Bad Request**           | Missing bid         | `{"error": "Business ID is required."}`         |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`             |
| **500 Internal Server Error** | Server Error        | `{"error": "C0STAFFERR: <error_message>"}`      |

---

### 53. User Logout

Logs out the authenticated user by invalidating the token.

- **Endpoint:** `/api/logout/`
- **Method:** `POST`
- **Authentication:** Required (JWT Token)
- **Headers:** `Authorization: Bearer <access_token>`

#### Responses:

| Status Code                   | Scenario         | Body                                        |
| :---------------------------- | :--------------- | :------------------------------------------ |
| **200 OK**                    | Success          | `{"message": "Successfully logged out."}`   |
| **401 Unauthorized**          | No/Invalid Token | Authentication error                        |
| **500 Internal Server Error** | Server Error     | `{"error": "C0LOGOUTERR: <error_message>"}` |

---

### 54. Get Maintenance & Cleaning Units

Returns all rooms and tables for a business that are currently in **Maintenance** or **Cleaning** status.

- **Endpoint:** `/api/maintenance/?bid=<business_id>`
- **Method:** `GET`
- **Authentication:** Required

#### Query Parameters:

| Parameter | Type    | Required | Description              |
| :-------- | :------ | :------- | :----------------------- |
| `bid`     | Integer | Yes      | Business ID to filter by |

#### Response (200 OK):

```json
{
  "rooms": [
    {
      "id": 3,
      "room_number": "101",
      "type_id": 1,
      "type_name": "Deluxe",
      "price": "2500.00",
      "capacity": 2,
      "status_id": 3,
      "status_name": "Maintenance",
      "business_id": 1
    }
  ],
  "tables": [
    {
      "id": 5,
      "table_number": "T-03",
      "capacity": 4,
      "status_id": 2,
      "status_name": "Cleaning",
      "business_id": 1
    }
  ]
}
```

> **Note:** Both `rooms` and `tables` arrays will be empty `[]` if no units are currently in maintenance or cleaning.

#### Error Responses:

| Status Code          | Scenario           | Body                                                          |
| :------------------- | :----------------- | :------------------------------------------------------------ |
| **400 Bad Request**  | `bid` not provided | `{"error": "bid (business_id) query parameter is required."}` |
| **400 Bad Request**  | Invalid `bid`      | `{"error": "Invalid business_id."}`                           |
| **401 Unauthorized** | No/Invalid Token   | Authentication error                                          |

---

### 55. Mark Unit as Available

Marks a room or table as **Available**. Only units currently in **Maintenance** or **Cleaning** status can be updated.

- **Endpoint:** `/api/maintenance/`
- **Method:** `PUT`
- **Authentication:** Required
- **Content-Type:** `application/json`

#### Request Body:

| Field         | Type    | Required | Description                      |
| :------------ | :------ | :------- | :------------------------------- |
| `type`        | String  | Yes      | Unit type: `"room"` or `"table"` |
| `id`          | Integer | Yes      | ID of the room or table          |
| `business_id` | Integer | Yes      | Business the unit belongs to     |

```json
{
  "type": "room",
  "id": 3,
  "business_id": 1
}
```

#### Response (200 OK) — Room:

```json
{
  "message": "Room 101 marked as Available.",
  "room": {
    "id": 3,
    "room_number": "101",
    "type_id": 1,
    "type_name": "Deluxe",
    "price": "2500.00",
    "capacity": 2,
    "status_id": 1,
    "status_name": "Available",
    "business_id": 1
  }
}
```

#### Response (200 OK) — Table:

```json
{
  "message": "Table T-03 marked as Available.",
  "table": {
    "id": 5,
    "table_number": "T-03",
    "capacity": 4,
    "status_id": 1,
    "status_name": "Available",
    "business_id": 1
  }
}
```

#### Error Responses:

| Status Code                   | Scenario                                        | Body                                                                                   |
| :---------------------------- | :---------------------------------------------- | :------------------------------------------------------------------------------------- |
| **400 Bad Request**           | Missing `type`, `id`, or `business_id`          | `{"error": "type, id, and business_id are required."}`                                 |
| **400 Bad Request**           | `type` is not `"room"` or `"table"`             | `{"error": "type must be either \"room\" or \"table\"."}`                              |
| **400 Bad Request**           | Invalid `business_id`                           | `{"error": "Invalid business_id."}`                                                    |
| **400 Bad Request**           | Unit not in Maintenance/Cleaning state          | `{"error": "Room is not in a maintenance/cleaning state. Current status: Available."}` |
| **401 Unauthorized**          | No/Invalid Token                                | Authentication error                                                                   |
| **404 Not Found**             | Room/Table not found for this business          | `{"error": "Room not found for this business."}`                                       |
| **500 Internal Server Error** | `Available` status missing from DB status table | `{"error": "Available status not found in room_status table."}`                        |

---

### 52. Housekeeping Status

Health check endpoint for housekeeping status.

- **Endpoint:** `/api/housekeeping/`
- **Method:** `GET`
- **Authentication:** Not Required (AllowAny)

#### Response (200 OK):

```json
{
  "message": "URL endpoint is working."
}
```

---

## Revenue APIs

The Revenue APIs provide endpoints to calculate and retrieve revenue data for a business. Revenue is calculated from two primary sources:

1. **Room Revenue**: Generated from successful room bookings and payments
2. **Cafe Revenue**: Generated from cafe orders with status 'Completed', 'Served', or 'Paid'

### Revenue Calculation Overview

Revenue is calculated on a **daily basis** and automatically refreshes each day to show the current day's revenue. The system aggregates:

- **Room Bookings Revenue**: Payments marked as 'Paid' for room bookings
- **Cafe Orders Revenue**: Orders with completion or payment status
- **Total Revenue**: Sum of room revenue and cafe revenue

---

### 1. Get Revenue by Business ID

Retrrieves today's total revenue for a specified business, including breakdowns of room and cafe revenue.

- **Endpoint:** `/api/revenue/b<int:business_id>/`
- **Method:** `GET`
- **Authentication:** Not Required (AllowAny)
- **Query Parameters:**
  - `bid` (optional): Alternative way to pass business_id via query parameter

#### URL Examples:

```
/api/revenue/b1/
/api/revenue/?bid=1
```

#### Response (200 OK):

```json
{
  "business_id": 1,
  "date": "2026-04-01",
  "room_revenue": 5000.0,
  "cafe_revenue": 2500.0,
  "total_revenue": 7500.0
}
```

#### Response Fields:

| Field             | Type                | Description                                                               |
| :---------------- | :------------------ | :------------------------------------------------------------------------ |
| **business_id**   | Integer             | The ID of the business                                                    |
| **date**          | String (YYYY-MM-DD) | The date for which revenue is calculated (today's date)                   |
| **room_revenue**  | Float               | Total revenue from room bookings (payments marked as 'Paid')              |
| **cafe_revenue**  | Float               | Total revenue from cafe orders (status: 'Completed', 'Served', or 'Paid') |
| **total_revenue** | Float               | Sum of room_revenue and cafe_revenue                                      |

#### Responses:

| Status Code                   | Scenario            | Body                                     |
| :---------------------------- | :------------------ | :--------------------------------------- |
| **200 OK**                    | Success             | Revenue data with breakdown              |
| **400 Bad Request**           | Missing business_id | `{"error": "Business ID is required."}`  |
| **400 Bad Request**           | Invalid business_id | `{"error": "Invalid business_id."}`      |
| **500 Internal Server Error** | Server Error        | `{"error": "C0REVERR: <error_message>"}` |

---

### 2. Revenue Data Sources

#### Room Revenue Sources

Room revenue is calculated from successful payments linked to room bookings:

- **Model**: `payment`
- **Filters Applied**:
  - `booking_id__business_id`: Matches the specified business
  - `paid_at`: Falls within today's date range (00:00:00 to 23:59:59)
  - `status_id__name`: Must be 'Paid'
- **Aggregation**: Sum of `amount` field

#### Cafe Revenue Sources

Cafe revenue is calculated from completed cafe orders:

- **Model**: `cafe_order`
- **Filters Applied**:
  - `business_id`: Matches the specified business
  - `created_at`: Falls within today's date range (00:00:00 to 23:59:59)
  - `status_id__name`: Must be 'Completed', 'Served', or 'Paid'
- **Aggregation**: Sum of `total_amount` field

---

### 3. Implementation Details

#### Service Function: `calculate_revenue(business_id)`

**Location**: [api/services/dashboardServices.py](api/services/dashboardServices.py)

The `calculate_revenue()` function performs the actual revenue calculation:

```python
def calculate_revenue(business_id):
    """
    Calculate today's total revenue for the specified business.
    Automatically refreshes each day showing current day's revenue.

    Args:
        business_id: The business ID to calculate revenue for

    Returns:
        dict: Today's revenue data with breakdown
    """
```

**Key Features**:

- Validates business existence before calculation
- Uses local timezone for accurate daily calculations
- Performs date filtering at database level for optimal performance
- Returns float values for all monetary amounts
- Handles missing data gracefully (defaults to 0)

---

### 4. Usage Examples

#### Example 1: Get Today's Revenue

**Request**:

```bash
curl -X GET "http://localhost:8000/api/revenue/b1/" \
  -H "Content-Type: application/json"
```

**Response**:

```json
{
  "business_id": 1,
  "date": "2026-04-01",
  "room_revenue": 15000.0,
  "cafe_revenue": 4500.0,
  "total_revenue": 19500.0
}
```

#### Example 2: Get Revenue Using Query Parameter

**Request**:

```bash
curl -X GET "http://localhost:8000/api/revenue/?bid=1" \
  -H "Content-Type: application/json"
```

**Response**:

```json
{
  "business_id": 1,
  "date": "2026-04-01",
  "room_revenue": 15000.0,
  "cafe_revenue": 4500.0,
  "total_revenue": 19500.0
}
```

#### Example 3: Error Case - Missing Business ID

**Request**:

```bash
curl -X GET "http://localhost:8000/api/revenue/" \
  -H "Content-Type: application/json"
```

**Response** (400 Bad Request):

```json
{
  "error": "Business ID is required."
}
```

#### Example 4: Error Case - Invalid Business ID

**Request**:

```bash
curl -X GET "http://localhost:8000/api/revenue/b999/" \
  -H "Content-Type: application/json"
```

**Response** (400 Bad Request):

```json
{
  "error": "Invalid business_id."
}
```

---

### 5. Additional Notes on Revenue

**Time Zone Handling**:

- All revenue calculations use the local timezone (configured in Django settings)
- Date range is 00:00:00 to 23:59:59 of the current day
- Automatically adjusts for timezone differences

**Real-Time Updates**:

- Revenue data is calculated in real-time on each request
- No caching is applied to ensure latest data
- Each day's data is independent and isolated

**Status Dependencies**:

- Room Revenue: Relies on payment status being exactly 'Paid'
- Cafe Revenue: Includes orders with 'Completed', 'Served', OR 'Paid' status
- Only confirmed/completed transactions are counted

**Database Optimization**:

- Queries use Django ORM aggregation for efficient calculation
- Filtering happens at the database level
- No N+1 queries are involved in revenue calculation

---

## Super Admin APIs

### 52. Create Business

Creates a new business entity in the system.

- **Endpoint:** `/super-admin/business/`
- **Method:** `POST`
- **Authentication:** Not Required (AllowAny)
- **Request Body:**

```json
{
  "name": "string",
  "business_type_id": "int",
  "phone_number": "string",
  "pan_number": "string",
  "address": "string",
  "email": "string"
}
```

#### Response (201 Created):

```json
{
  "success": true,
  "message": "Business created successfully.",
  "business": {
    "id": 1,
    "name": "John's Cafe",
    "business_type_id": 1,
    "phone_number": "9876543210",
    "pan_number": "ABCDE1234F",
    "address": "123 Main Street",
    "email": "cafe@example.com",
    "uid": "uuid-string",
    "created_at": "2026-04-02T10:00:00Z",
    "updated_at": "2026-04-02T10:00:00Z"
  }
}
```

#### Responses:

| Status Code                   | Scenario        | Body                                                     |
| :---------------------------- | :-------------- | :------------------------------------------------------- |
| **201 Created**               | Success         | `{"success": true, "message": "...", "business": {...}}` |
| **400 Bad Request**           | Missing Fields  | `{"success": false, "error": "<error_message>"}`         |
| **400 Bad Request**           | Invalid Type ID | `{"error": "Invalid business type ID."}`                 |
| **500 Internal Server Error** | Server Error    | `{"error": "Unexpected error: <error_message>"}`         |

---

### 53. Get All Plans

Retrieves all available subscription plans.

- **Endpoint:** `/super-admin/plans/`
- **Method:** `GET`
- **Authentication:** Not Required (AllowAny)

#### Response (200 OK):

```json
[
  {
    "id": 1,
    "name": "Basic Plan",
    "price": "99.99",
    "max_rooms": 10,
    "max_branches": 1,
    "max_staff": 5,
    "is_active": true,
    "description": "Basic plan for small businesses",
    "status_id": 1,
    "status_name": "Active",
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-04-02T10:00:00Z"
  },
  {
    "id": 2,
    "name": "Premium Plan",
    "price": "299.99",
    "max_rooms": 100,
    "max_branches": 5,
    "max_staff": 50,
    "is_active": true,
    "description": "Premium plan for large businesses",
    "status_id": 1,
    "status_name": "Active",
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-04-02T10:00:00Z"
  }
]
```

#### Responses:

| Status Code                   | Scenario     | Body                           |
| :---------------------------- | :----------- | :----------------------------- |
| **200 OK**                    | Success      | `[<plan_objects>]`             |
| **500 Internal Server Error** | Server Error | `{"error": "<error_message>"}` |

---

### 54. Get Plan by ID

Retrieves a specific subscription plan by its ID.

- **Endpoint:** `/super-admin/plans/<plan_id>/`
- **Method:** `GET`
- **Authentication:** Not Required (AllowAny)
- **URL Parameters:**
  - `plan_id` (required): Integer - The plan ID

#### Response (200 OK):

```json
{
  "id": 1,
  "name": "Basic Plan",
  "price": "99.99",
  "max_rooms": 10,
  "max_branches": 1,
  "max_staff": 5,
  "is_active": true,
  "description": "Basic plan for small businesses",
  "status_id": 1,
  "status_name": "Active",
  "created_at": "2026-01-01T00:00:00Z",
  "updated_at": "2026-04-02T10:00:00Z"
}
```

#### Responses:

| Status Code                   | Scenario       | Body                           |
| :---------------------------- | :------------- | :----------------------------- |
| **200 OK**                    | Success        | `{<plan_object>}`              |
| **404 Not Found**             | Plan Not Found | `{"error": "Plan not found."}` |
| **500 Internal Server Error** | Server Error   | `{"error": "<error_message>"}` |

---

### 55. Create Plan

Creates a new subscription plan.

- **Endpoint:** `/super-admin/plans/`
- **Method:** `POST`
- **Authentication:** Not Required (AllowAny)
- **Request Body:**

```json
{
  "name": "string",
  "price": "decimal",
  "max_rooms": "int",
  "max_branches": "int",
  "max_staff": "int",
  "is_active": true,
  "description": "string",
  "status_id": "int"
}
```

#### Response (201 Created):

```json
{
  "success": true,
  "message": "Plan created successfully.",
  "plan": {
    "id": 3,
    "name": "Enterprise Plan",
    "price": "999.99",
    "max_rooms": 1000,
    "max_branches": 50,
    "max_staff": 500,
    "is_active": true,
    "description": "Enterprise plan for large organizations",
    "status_id": 1,
    "status_name": "Active",
    "created_at": "2026-04-02T10:00:00Z",
    "updated_at": "2026-04-02T10:00:00Z"
  }
}
```

#### Responses:

| Status Code                   | Scenario       | Body                                                 |
| :---------------------------- | :------------- | :--------------------------------------------------- |
| **201 Created**               | Success        | `{"success": true, "message": "...", "plan": {...}}` |
| **400 Bad Request**           | Missing Fields | `{"success": false, "error": "<error_message>"}`     |
| **400 Bad Request**           | Invalid Data   | `{"error": "<error_message>"}`                       |
| **500 Internal Server Error** | Server Error   | `{"error": "Unexpected error: <error_message>"}`     |

---

### 56. Update Plan

Updates an existing subscription plan.

- **Endpoint:** `/super-admin/plans/<plan_id>/`
- **Method:** `PUT`
- **Authentication:** Not Required (AllowAny)
- **URL Parameters:**
  - `plan_id` (required): Integer - The plan ID
- **Request Body:** (All fields optional for partial updates)

```json
{
  "name": "string",
  "price": "decimal",
  "max_rooms": "int",
  "max_branches": "int",
  "max_staff": "int",
  "is_active": true,
  "description": "string",
  "status_id": "int"
}
```

#### Response (200 OK):

```json
{
  "message": "Plan updated successfully.",
  "plan": {
    "id": 1,
    "name": "Basic Plan Updated",
    "price": "129.99",
    "max_rooms": 15,
    "max_branches": 2,
    "max_staff": 10,
    "is_active": true,
    "description": "Updated basic plan for small businesses",
    "status_id": 1,
    "status_name": "Active",
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-04-02T10:00:00Z"
  }
}
```

#### Responses:

| Status Code                   | Scenario       | Body                                                       |
| :---------------------------- | :------------- | :--------------------------------------------------------- |
| **200 OK**                    | Success        | `{"message": "Plan updated successfully.", "plan": {...}}` |
| **404 Not Found**             | Plan Not Found | `{"error": "Plan not found."}`                             |
| **400 Bad Request**           | Invalid Data   | `{"error": {...}}`                                         |
| **500 Internal Server Error** | Server Error   | `{"error": "Unexpected error: <error_message>"}`           |

---

### 57. Delete Plan

Deletes a subscription plan.

- **Endpoint:** `/super-admin/plans/<plan_id>/`
- **Method:** `DELETE`
- **Authentication:** Not Required (AllowAny)
- **URL Parameters:**
  - `plan_id` (required): Integer - The plan ID

#### Response (200 OK):

```json
{
  "message": "Plan deleted successfully."
}
```

#### Responses:

| Status Code                   | Scenario       | Body                                             |
| :---------------------------- | :------------- | :----------------------------------------------- |
| **200 OK**                    | Success        | `{"message": "Plan deleted successfully."}`      |
| **404 Not Found**             | Plan Not Found | `{"error": "Plan not found."}`                   |
| **500 Internal Server Error** | Server Error   | `{"error": "Unexpected error: <error_message>"}` |

---

## Error Codes Reference

### Standard Error Codes

| Error Code      | Description                                            | HTTP Status |
| :-------------- | :----------------------------------------------------- | :---------- |
| **C0INSERR**    | Internal server error - Generic error                  | 500         |
| **C0UPDERR**    | Update operation error                                 | 500         |
| **C0DELERR**    | Delete operation error                                 | 500         |
| **C0PAYERR**    | Payment operation error                                | 500         |
| **C0STATERR**   | Status retrieval error                                 | 500         |
| **C0CHKINERR**  | Check-in/Check-out operation error                     | 500         |
| **C0MENUERR**   | Menu operation error                                   | 500         |
| **C0STAFFERR**  | Staff operation error                                  | 500         |
| **C0LOGOUTERR** | Logout operation error                                 | 500         |
| **C1INSERR**    | Database related error (IntegrityError, DatabaseError) | 500         |
| **C2INSERR**    | Bad gateway - HTTP error in external request           | 502         |
| **C3INSERR**    | Service unavailable - Connection error                 | 503         |
| **C4INSERR**    | Gateway timeout - Request timeout                      | 504         |
| **C5INSERR**    | Model does not exist error                             | 500         |

### Common HTTP Status Codes

| Status Code                   | Meaning                                       |
| :---------------------------- | :-------------------------------------------- |
| **200 OK**                    | Request successful                            |
| **201 Created**               | Resource created successfully                 |
| **400 Bad Request**           | Invalid request data or missing fields        |
| **401 Unauthorized**          | Authentication required or invalid token      |
| **404 Not Found**             | Resource not found                            |
| **409 Conflict**              | Resource conflict (e.g., overlapping booking) |
| **500 Internal Server Error** | Server-side error                             |
| **502 Bad Gateway**           | External service error                        |
| **503 Service Unavailable**   | Service temporarily unavailable               |
| **504 Gateway Timeout**       | Request timeout                               |

---

## Data Models Reference

### Core Entities

| Entity            | Description                                 |
| :---------------- | :------------------------------------------ |
| **Business**      | Represents a hotel or restaurant business   |
| **User**          | Django User model for authentication        |
| **Staff**         | Employee of a business with role and shift  |
| **Guest**         | Customer/visitor record                     |
| **Room**          | Hotel room with type, capacity, and pricing |
| **Table**         | Restaurant/cafe table                       |
| **Booking**       | Room reservation record                     |
| **Invoice**       | Billing document for guests                 |
| **Payment**       | Payment transaction record                  |
| **Cafe Order**    | Restaurant/cafe order                       |
| **Order Item**    | Individual items in an order                |
| **Food Item**     | Menu item with pricing                      |
| **Food Category** | Category for food items                     |

### Status Types

| Entity             | Available Statuses                         |
| :----------------- | :----------------------------------------- |
| **Room Status**    | Available, Occupied, Maintenance           |
| **Booking Status** | Booked, Checked_in, Checked_out, Cancelled |
| **Staff Status**   | Active, On_Leave, Inactive                 |
| **Guest Status**   | Active, Inactive                           |
| **Order Status**   | Pending, In Progress, Completed, Cancelled |
| **Payment Status** | Pending, Completed, Failed, Refunded       |
| **Invoice Status** | Pending, Paid, Overdue, Cancelled          |

---

## Authentication Flow

### 1. Registration

```
POST /api/signup/
→ Creates User + Business
→ Returns success message
```

### 2. Login

```
POST /api/login/ (phone_number, password)
→ Returns JWT tokens (access + refresh)
```

### 3. API Requests

```
Include header: Authorization: Bearer <access_token>
→ Access protected endpoints
```

### 4. Token Refresh

```
POST /api/refresh-token/ (refresh token)
→ Returns new access token
```

### 5. Logout

```
POST /api/logout/
→ Invalidates token
```

---

## Quick Reference - Endpoint Summary

| Category        | Endpoints                                                                            |
| :-------------- | :----------------------------------------------------------------------------------- |
| **Auth**        | `/signup/`, `/login/`, `/logout/`, `/refresh-token/`                                 |
| **Staff**       | `/staff/`, `/staff/<id>/`                                                            |
| **Guest**       | `/guest/`, `/guest/<id>/`                                                            |
| **Food Items**  | `/food-item/`, `/food-item/<id>/`                                                    |
| **Tables**      | `/tables/`, `/tables/<id>/`                                                          |
| **Orders**      | `/order/t<table_id>`                                                                 |
| **Order Items** | `/order-items/`, `/order-items/<id>/`                                                |
| **Rooms**       | `/rooms/`, `/rooms/<id>/`                                                            |
| **Bookings**    | `/booking/`, `/booking/<id>/`                                                        |
| **Invoices**    | `/invoice/`, `/invoice/<id>/`                                                        |
| **Payments**    | `/payment/`, `/payment/<id>/`                                                        |
| **Dashboard**   | `/room-status/`, `/check-in/`, `/check-out/`, `/booked/`, `/menu/`, `/staff-status/` |
| **Maintenance** | `/maintenance/`                                                                      |
| **Utility**     | `/housekeeping/`                                                                     |

---

## License

This project is proprietary software. All rights reserved.
