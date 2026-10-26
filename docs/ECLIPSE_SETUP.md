# Eclipse IDE for Enterprise Java: Import & Configuration Guide

## 1. Prerequisites
- **Eclipse IDE**: Eclipse IDE for Enterprise Java and Web Developers (2023-12, 2024-03, or newer).
- **Installed JRE/JDK**: Eclipse configured with Java 17+ Execution Environment.
- **Apache Tomcat**: Tomcat 10.1.x extracted or installed on local filesystem.

---

## 2. Step-by-Step Project Import
1. Open Eclipse and select your desired workspace directory.
2. Go to **File -> Import...**
3. Expand the **Maven** folder, select **Existing Maven Projects**, and click **Next >**.
4. In **Root Directory**, click **Browse...** and select the HostelEase project folder:
   `c:\Users\Lenovo\OneDrive\Desktop\hostelease\project1`
5. Eclipse will scan and detect `pom.xml` with artifact ID `HostelEase`. Ensure the checkbox is checked.
6. Click **Finish**. Eclipse will import and configure the project facets automatically.

---

## 3. Configuring Apache Tomcat 10.1 Server in Eclipse
1. Open the **Servers** view in Eclipse (**Window -> Show View -> Servers**).
2. Right-click in the empty Servers window and select **New -> Server**.
3. In the wizard:
   - Select **Apache -> Tomcat v10.1 Server**.
   - Server's host name: `localhost`.
   - Click **Next >**.
4. Specify the **Tomcat installation directory**:
   - e.g., `C:\apache-tomcat-10.1` or `C:\Program Files\Apache Software Foundation\Tomcat 10.1`.
   - Ensure the **JRE** is set to **Java 17 (or compatible JDK)**.
5. In the **Add and Remove** pane:
   - Select **HostelEase** from the **Available** list on the left.
   - Click **Add >** to move it to **Configured**.
6. Click **Finish**.

---

## 4. Running & Debugging the Application
1. In the **Project Explorer**, right-click the `HostelEase` project node.
2. Select **Run As -> Run on Server** (or press `Alt + Shift + X, R`).
3. Select **Tomcat v10.1 Server at localhost** and click **Finish**.
4. Tomcat will initialize HikariCP connection pool, verify the database schema, start the background scheduler, and launch the application.
5. Access the application in your browser at:
   ```
   http://localhost:8080/HostelEase/
   ```

### Debugging with Breakpoints
- You can place standard Eclipse breakpoints in any controller (`AdminDashboardServlet.java`, `WardenLeaveServlet.java`), service, or DAO.
- Select **Debug As -> Debug on Server** (`Alt + Shift + X, D`) to inspect variable states, connection queries, and execution paths interactively.

---

## 5. Troubleshooting Eclipse Facet Warnings
If Eclipse displays facet configuration warnings:
1. Right-click project -> **Properties -> Project Facets**.
2. Ensure:
   - **Dynamic Web Module**: `6.0` (for Jakarta Servlet 6.0 / Tomcat 10.1)
   - **Java**: `17`
3. Click **Apply and Close**.
4. Right-click project -> **Maven -> Update Project...** (or press `Alt + F5`), check **Force Update of Snapshots/Releases**, and click **OK**.
