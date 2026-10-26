# HostelEase — End-User Operations Manual & Role Walkthroughs

## 1. Quick Access Credentials
| Role | Login Identifier | Password | Primary Mission |
|---|---|---|---|
| **Administrator** | `admin` | `Admin@123` | Institutional oversight, room allocations, fee billing, and audit reports |
| **Boys Warden** | `warden.boys` | `Warden@123` | Aryabhatta Boys Hostel gate security, leave reviews, and maintenance |
| **Girls Warden** | `warden.girls` | `Warden@123` | Gargi Girls Hostel gate security, leave reviews, and maintenance |
| **Student Resident**| `student1@hostelease.com` | `Student@123` | Room resident portal, leave requests, complaint filing, fee payments |

---

## 2. Administrator Persona Walkthrough

### 2.1 Executive Dashboard
- Navigate to `/admin/dashboard`.
- Real-time stat cards display Total Rooms, Total Beds, Allocated Beds, and Institutional Occupancy Rate.
- Interactive Chart.js graphs render occupancy distribution and monthly fee collection velocity.

### 2.2 Visual Bed Matrix & Inspection
- Navigate to `/admin/rooms`.
- The visual grid displays every hostel building, floor, and room.
- Color coding:
  - **Green**: Occupied & Present.
  - **Amber**: Away on Leave (Temporary Vacancy).
  - **Red Pulse**: Return Overdue.
  - **Blue**: Available (Unallocated).
- Click any bed chip to open the **Bed Inspector Modal** displaying occupant name, registration number, presence status, and emergency contacts.

### 2.3 Room Allocations & Transfers
- Navigate to `/admin/allocations`.
- **New Allocation**: Select an unallocated student from the searchable dropdown, select an available vacant bed, and click "Allocate Bed". The backend uses atomic check-and-set transactions to prevent double-allocations.
- **Inter-Room Transfer**: Transfer an active resident to another vacant bed in one atomic transaction without manual deallocation.
- **Permanent Checkout**: Ends residency, deactivates the allocation, and marks the bed as available.

### 2.4 Financial & Fee Management
- Navigate to `/admin/fees`.
- View billed invoices, payments received, and outstanding balances.
- Click **"Pay"** on any invoice with a balance to open the **Record Payment Modal**, specify payment mode (UPI, NEFT, Cash), transaction UTR reference, and issue an instant official receipt.

### 2.5 Compliance & Audit Reports
- Navigate to `/admin/reports`.
- Tabbed reports:
  1. **Occupancy Matrix**: Complete institutional census.
  2. **Holiday Away & Vacancies**: Audits beds whose student is away on approved leave.
  3. **Overdue Returns**: Roster of late students with direct emergency phone call buttons.
  4. **Fee Collections**: Revenue audit ledger.
  5. **Maintenance**: Facility work order register.
- Click **"Print Report"** for an executive print-formatted document.

---

## 3. Warden Persona Walkthrough

### 3.1 Facility Supervision Console
- Navigate to `/warden/dashboard`.
- Automatically filtered to the warden's assigned building.
- Summarizes occupied beds, residents currently away, pending leaves, and active visitors.

### 3.2 Leave & Holiday Authorizations
- Navigate to `/warden/leaves`.
- Filter applications by `PENDING`, `APPROVED`, `DEPARTED`, `OVERDUE`.
- Click the green checkmark to **Approve** or red cross to **Reject** an application with custom logged remarks.

### 3.3 Gate Checkpoint (Departure & Return Execution)
- Navigate to `/warden/presence`.
- **Approved Departures**: Click **"Confirm Departure (Gate Out)"** when the student leaves through the gate. This sets their presence to `AWAY` and marks the bed as temporarily vacant while protecting their allocation lock.
- **Residents Away**: Click **"Confirm Return (Gate In)"** when the student arrives back at campus. This restores their presence to `PRESENT` and updates room occupancy.
- **Overdue Returns Alert**: Displays overdue students in red pulse with guardian phone numbers for immediate contact.

### 3.4 Visitor Security Pass Management
- Navigate to `/warden/visitors`.
- Click **"Register New Visitor"** to log visitor name, contact phone, resident visited, and government ID proof (Aadhaar, Driving License).
- When the visitor departs, click **"Check Out"** to record the exit timestamp.

### 3.5 Facility Maintenance Tickets
- Navigate to `/warden/complaints`.
- View tickets lodged by residents.
- Click **"Update"** to change status (`IN_PROGRESS`, `RESOLVED`, `CLOSED`) and log technician notes.

---

## 4. Student Resident Persona Walkthrough

### 4.1 Resident Portal Dashboard
- Navigate to `/student/dashboard`.
- Displays allocated hostel, room number, bed number, and physical presence state.
- Features latest hostel circulars and quick navigation buttons.

### 4.2 Applying for Holiday & Leave
- Navigate to `/student/leaves`.
- Fill in:
  - Leave Category (Home Visit, Vacation, Medical, Emergency, Academic OD).
  - Departure Date/Time and Return Date/Time.
  - Destination Address and Guardian Emergency Contact.
  - Reason for absence.
- Click **"Submit Leave Application"**. Your parent is alerted and the warden is notified for review.
- Your bed allocation remains 100% reserved for you while you are away.

### 4.3 Lodging Maintenance Requests
- Navigate to `/student/complaints`.
- Select category (Electrical, Plumbing, Carpentry, Housekeeping, WiFi, Mess).
- Select priority and describe the issue.
- Track resolution status and technician remarks in the history table.

### 4.4 Paying Fees & Downloading Receipts
- Navigate to `/student/fees`.
- Check invoiced fees and remaining balance.
- Click **"Pay Online"** to open the payment gateway simulation modal.
- Select payment method (UPI, Card, Net Banking) and click **"Authorize & Pay Now"** for instant receipt generation.

### 4.5 Resident Profile
- Navigate to `/student/profile`.
- Verify academic records, emergency contacts, permanent home address, and room credentials.
