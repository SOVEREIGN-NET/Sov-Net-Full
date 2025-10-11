# SOVEREIGN NET - Complete Architecture Flow

## Overview
This document traces the complete code path from browser → API → blockchain → contracts → DHT → DNS and back to browser for site hosting.

---

## 1. BROWSER LAYER (`/browser`)

### Entry Point: `main.js`
- **Purpose**: Electron app that manages the ZHTP backend node
- **Key Functions**:
  - `ensureZhtpNodeRunning()` - Checks if ZHTP node is running on port 9333
  - `startZhtpNode()` - Spawns `./target/debug/zhtp.exe node start --dev --port 9333`
  - Creates BrowserWindow with `nodeIntegration: true` for native access

### Browser App: `src/app.js`
- **Purpose**: Main Web4 browser application (10,414 lines)
- **Key Components**:
  - `Web4Browser` class - Main browser controller
  - DAO integration - Proposal system, voting, treasury
  - Identity management - Sign-in, wallet creation
  - Navigation - URL handling, page rendering

### API Client: `src/api/zhtp-api.js`
- **Purpose**: Pure ZHTP mesh protocol client (1,742 lines)
- **Protocol**: UDP-based native mesh communication
- **Key Classes**:
  ```javascript
  class PureZhtpConnection {
      host = '127.0.0.1';
      port = 9333;
      meshSocket; // UDP dgram socket
      
      async connect() { /* UDP handshake */ }
      async sendMeshRequest(zhtpRequest) { /* Native ZHTP protocol */ }
      serializeZhtpMeshRequest(request) { /* Binary protocol */ }
      deserializeZhtpResponse(buffer) { /* Parse response */ }
  }
  ```

**Browser → Server Communication**:
```
Browser (Electron)
    ↓ UDP dgram socket
    ↓ Port 9333
    ↓ Native ZHTP protocol (binary)
ZHTP Unified Server
```

---

## 2. ZHTP BACKEND SERVER (`/zhtp`)

### Orchestrator: `src/main.rs` + `src/runtime/mod.rs`
- **Purpose**: Level 1 orchestrator - coordinates all systems
- **Components Initialized**:
  1. `crypto` - Post-quantum cryptography (Dilithium, Kyber)
  2. `zk` - Zero-knowledge proof system
  3. `identity` - lib-identity system
  4. `storage` - Unified storage + DHT
  5. `network` - Mesh networking
  6. `blockchain` - Blockchain + UTXO system
  7. `consensus` - DAO + BFT consensus
  8. `economics` - UBI + token economics
  9. `protocols` - ZHTP Unified Server

### Unified Server: `src/unified_server.rs`
- **Purpose**: Single server handling ALL protocols on port 9333 (3,957 lines)
- **Protocol Detection**: Automatically detects HTTP/UDP/TCP/WiFi/Bluetooth
- **Key Features**:
  ```rust
  pub struct ZhtpUnifiedServer {
      http_router: HttpRouter,
      session_manager: SessionManager,
      blockchain: Arc<RwLock<Blockchain>>,
      storage: Arc<RwLock<UnifiedStorageSystem>>,
      web4_handler: Arc<Web4Handler>,
      dns_handler: Arc<DnsHandler>,
      dht_handler: Arc<DhtHandler>,
      // ... more handlers
  }
  ```

**Protocol Flow**:
```
Port 9333 Listener
    ↓
Protocol Detection
    ├─→ HTTP API (REST endpoints)
    ├─→ UDP Mesh (ZHTP native)
    ├─→ TCP (Bootstrap)
    ├─→ WiFi Direct
    └─→ Bluetooth
```

---

## 3. API HANDLERS (`/zhtp/src/api/handlers`)

### Web4 Handler: `handlers/web4/mod.rs`
- **Purpose**: Web4 domain & content management
- **Key Endpoints**:
  - `POST /api/v1/web4/domains/register` - Register domain
  - `GET /api/v1/web4/serve/{domain}/{path}` - Serve content
  - `POST /api/v1/web4/content/publish` - Publish site content
  - `GET /api/v1/web4/statistics` - System stats

**Web4 Handler Flow**:
```rust
impl ZhtpRequestHandler for Web4Handler {
    async fn handle_request(&self, request: ZhtpRequest) -> ZhtpResult<ZhtpResponse> {
        match request.uri.as_str() {
            "/api/v1/web4/domains/register" => self.register_domain_simple(request.body).await,
            path if path.starts_with("/api/v1/web4/serve/") => {
                self.serve_domain_content(request).await
            }
            // ... more routes
        }
    }
}
```

### DNS Handler: `handlers/dns/mod.rs`
- **Purpose**: DNS → DHT resolution (ZDNS system)
- **Integration**: Works with Web4Manager for domain lookups

### Blockchain Handler: `handlers/blockchain/mod.rs`
- **Purpose**: Blockchain queries and transactions
- **Key Endpoints**:
  - `GET /api/v1/blockchain/info` - Chain info
  - `POST /api/v1/blockchain/contract/call` - Execute contract
  - `POST /api/v1/blockchain/transaction/submit` - Submit tx

---

## 4. WEB4 SYSTEM (`/lib-network/src/web4`)

### Web4Manager: `lib-network/src/web4/domain_registry.rs`
- **Purpose**: Domain registry with DHT backend
- **Key Features**:
  ```rust
  pub struct Web4Manager {
      pub registry: DomainRegistry,
      pub content_publisher: ContentPublisher,
      pub dht_client: Arc<RwLock<DhtClient>>,
  }
  ```

### Domain Registry Operations:
1. **Register Domain**:
   ```rust
   async fn register_domain(
       &mut self, 
       domain: String, 
       owner: PublicKey
   ) -> Result<String>
   ```
   - Creates domain record
   - Stores in DHT: `domain:{name}` → DomainInfo
   - Creates Web4 contract on blockchain

2. **Publish Content**:
   ```rust
   async fn publish_content(
       &mut self, 
       domain: String, 
       content: HashMap<String, Vec<u8>>
   ) -> Result<String>
   ```
   - Stores each file in DHT: `content:{hash}` → file data
   - Updates domain record with content hashes
   - Stores routing information

3. **Serve Content**:
   ```rust
   async fn get_domain_content(
       &self, 
       domain: &str, 
       path: &str
   ) -> Result<Vec<u8>>
   ```
   - Looks up domain in DHT
   - Finds content hash for path
   - Retrieves content from DHT
   - Returns to browser

---

## 5. BLOCKCHAIN LAYER (`/lib-blockchain`)

### Smart Contracts: `src/contracts/web4/`

**Web4 Contract Structure**:
```rust
pub struct Web4Contract {
    pub domain: String,
    pub owner: PublicKey,
    pub content_hashes: HashMap<String, Hash>, // path → DHT hash
    pub metadata: WebsiteMetadata,
    pub routes: Vec<ContentRoute>,
}

impl Web4Contract {
    /// Register a new domain
    pub fn register_domain(
        domain: String, 
        owner: PublicKey
    ) -> ContractResult<Hash>
    
    /// Update content hashes
    pub fn update_content(
        &mut self, 
        path: String, 
        content_hash: Hash
    ) -> ContractResult<()>
    
    /// Transfer ownership
    pub fn transfer_ownership(
        &mut self, 
        new_owner: PublicKey
    ) -> ContractResult<()>
}
```

**Contract Operations**:
- Stored on blockchain as transactions
- Immutable ownership records
- Content hash references (not content itself)
- Smart contract execution for complex logic

---

## 6. DHT STORAGE (`/lib-network/src/dht`)

### DHT Client: `lib-network/src/dht/mod.rs`
- **Purpose**: Distributed hash table for content storage
- **Protocol**: Binary UDP protocol on port 33446

**DHT Storage Pattern**:
```rust
pub struct DhtClient {
    node_address: String,
    routing_table: RoutingTable,
    storage: DhtStorage,
}

// Store operations
async fn store(&mut self, key: String, value: Vec<u8>) -> Result<()>
async fn get(&self, key: String) -> Result<Option<Vec<u8>>>
async fn publish(&mut self, key: String, value: Vec<u8>) -> Result<()>
```

**Key Types**:
- `domain:{name}` - Domain metadata and owner info
- `content:{hash}` - Website content (HTML, CSS, JS, images)
- `route:{domain}/{path}` - Path routing information
- `contract:{id}` - Contract state references

---

## 7. COMPLETE FLOW: Hosting a Website

### Step-by-Step Process:

#### **Step 1: User Creates Site in Browser**
```javascript
// browser/src/app.js
async function createWebsite() {
    const domainName = "my-site.zhtp";
    const files = {
        "/index.html": "<html>...</html>",
        "/style.css": "body { color: blue; }",
        "/script.js": "console.log('Hello');"
    };
    
    // Call API to register domain and publish content
    const result = await zhtpApi.post('/api/v1/web4/domains/register', {
        domain: domainName,
        owner: currentIdentity.publicKey
    });
}
```

#### **Step 2: API Handler Receives Request**
```rust
// zhtp/src/api/handlers/web4/mod.rs
async fn register_domain_simple(&self, body: Vec<u8>) -> ZhtpResult<ZhtpResponse> {
    let request: DomainRegistrationRequest = serde_json::from_slice(&body)?;
    
    let mut manager = self.web4_manager.write().await;
    let domain_id = manager.registry.register_domain(
        request.domain,
        request.owner
    ).await?;
    
    // Returns domain ID and success status
}
```

#### **Step 3: Web4Manager Processes Registration**
```rust
// lib-network/src/web4/domain_registry.rs
async fn register_domain(&mut self, domain: String, owner: PublicKey) -> Result<String> {
    // 1. Validate domain name
    self.validate_domain_name(&domain)?;
    
    // 2. Check availability in DHT
    let existing = self.dht_client.read().await.get(format!("domain:{}", domain)).await?;
    if existing.is_some() {
        return Err(anyhow!("Domain already registered"));
    }
    
    // 3. Create domain record
    let domain_info = DomainInfo {
        domain: domain.clone(),
        owner: owner.clone(),
        registered_at: current_timestamp(),
        content_hashes: HashMap::new(),
        contract_id: None,
    };
    
    // 4. Store in DHT
    let domain_key = format!("domain:{}", domain);
    let domain_data = serde_json::to_vec(&domain_info)?;
    self.dht_client.write().await.store(domain_key, domain_data).await?;
    
    // 5. Create blockchain contract
    let contract_id = self.create_web4_contract(domain.clone(), owner).await?;
    
    // 6. Update domain with contract ID
    domain_info.contract_id = Some(contract_id);
    self.dht_client.write().await.store(domain_key, serde_json::to_vec(&domain_info)?).await?;
    
    Ok(contract_id)
}
```

#### **Step 4: Publish Content**
```rust
async fn publish_content(
    &mut self,
    domain: String,
    content: HashMap<String, Vec<u8>>
) -> Result<String> {
    // 1. Hash each file
    let mut content_hashes = HashMap::new();
    for (path, data) in content.iter() {
        let hash = blake3::hash(data);
        let hash_str = hash.to_hex().to_string();
        
        // 2. Store content in DHT
        let content_key = format!("content:{}", hash_str);
        self.dht_client.write().await.store(content_key, data.clone()).await?;
        
        content_hashes.insert(path.clone(), hash_str);
    }
    
    // 3. Update domain record with content hashes
    let domain_key = format!("domain:{}", domain);
    let mut domain_info: DomainInfo = /* load from DHT */;
    domain_info.content_hashes = content_hashes;
    self.dht_client.write().await.store(domain_key, serde_json::to_vec(&domain_info)?).await?;
    
    // 4. Update blockchain contract
    self.update_contract_content(domain_info.contract_id.unwrap(), domain_info.content_hashes).await?;
    
    Ok("Content published successfully".to_string())
}
```

#### **Step 5: User Visits Site in Browser**
```javascript
// browser/src/app.js
async function navigateTo(url) {
    // URL: zhtp://my-site.zhtp/index.html
    const domain = extractDomain(url); // "my-site.zhtp"
    const path = extractPath(url);     // "/index.html"
    
    // Request content from API
    const response = await zhtpApi.get(`/api/v1/web4/serve/${domain}${path}`);
    
    // Render in browser
    displayContent(response.data, response.contentType);
}
```

#### **Step 6: Server Serves Content**
```rust
// zhtp/src/api/handlers/web4/mod.rs
async fn serve_domain_content(&self, request: ZhtpRequest) -> ZhtpResult<ZhtpResponse> {
    let domain = extract_domain_from_uri(&request.uri);
    let path = extract_path_from_uri(&request.uri);
    
    let manager = self.web4_manager.read().await;
    
    // Get content from Web4Manager
    let content = manager.registry.get_domain_content(&domain, &path).await?;
    
    // Determine content type
    let content_type = determine_content_type(&path);
    
    // Return response
    Ok(ZhtpResponse::success_with_content_type(
        content,
        content_type,
        None
    ))
}
```

#### **Step 7: DHT Retrieves Content**
```rust
// lib-network/src/web4/domain_registry.rs
async fn get_domain_content(&self, domain: &str, path: &str) -> Result<Vec<u8>> {
    // 1. Get domain info from DHT
    let domain_key = format!("domain:{}", domain);
    let domain_data = self.dht_client.read().await.get(domain_key).await?
        .ok_or_else(|| anyhow!("Domain not found"))?;
    
    let domain_info: DomainInfo = serde_json::from_slice(&domain_data)?;
    
    // 2. Get content hash for path
    let content_hash = domain_info.content_hashes.get(path)
        .ok_or_else(|| anyhow!("Path not found"))?;
    
    // 3. Retrieve content from DHT
    let content_key = format!("content:{}", content_hash);
    let content = self.dht_client.read().await.get(content_key).await?
        .ok_or_else(|| anyhow!("Content not found in DHT"))?;
    
    Ok(content)
}
```

---

## 8. DATA FLOW DIAGRAM

```
┌─────────────────┐
│  Browser (JS)   │ User creates site, navigates to URLs
└────────┬────────┘
         │ UDP Mesh Protocol (Port 9333)
         ↓
┌─────────────────┐
│ Unified Server  │ Protocol detection, routing
└────────┬────────┘
         │
    ┌────┴────┬──────────┬──────────┐
    ↓         ↓          ↓          ↓
┌─────┐  ┌──────┐  ┌─────────┐  ┌──────┐
│Web4 │  │ DNS  │  │Blockchain│  │ DHT  │
│API  │  │Handler│  │ Handler │  │Handler│
└──┬──┘  └───┬──┘  └────┬────┘  └───┬──┘
   │         │          │            │
   └─────────┴──────┬───┴────────────┘
                    ↓
         ┌────────────────────┐
         │   Web4Manager      │
         │  - DomainRegistry  │
         │  - ContentPublisher│
         └──────┬─────┬───────┘
                │     │
        ┌───────┘     └──────────┐
        ↓                        ↓
┌───────────────┐      ┌──────────────┐
│  Blockchain   │      │  DHT Storage │
│   - Contracts │      │  - Content   │
│   - UTXO      │      │  - Domains   │
│   - State     │      │  - Routes    │
└───────────────┘      └──────────────┘
```

---

## 9. KEY INTEGRATION POINTS

### Browser ↔ Server
- **Protocol**: UDP mesh (ZHTP native)
- **Port**: 9333
- **Format**: Binary ZHTP protocol with JSON payloads

### Server ↔ Web4Manager
- **Integration**: `Arc<RwLock<Web4Manager>>` shared across handlers
- **Methods**: Direct async function calls

### Web4Manager ↔ DHT
- **Integration**: `Arc<RwLock<DhtClient>>` injected
- **Storage Pattern**: Key-value with namespacing
  - `domain:{name}` → Domain metadata
  - `content:{hash}` → File content

### Web4Manager ↔ Blockchain
- **Integration**: Contract creation and updates
- **Pattern**: Create contract → Store reference in DHT

### DNS ↔ DHT
- **Integration**: DNS queries resolved via DHT lookups
- **Pattern**: `domain:{name}` → IP/content hash

---

## 10. CURRENT ISSUE ANALYSIS

Based on your error logs, the browser timeout issue is:

### Problem:
```
ZHTP mesh request timeout (10 seconds)
zhtp-api.js:118 ⏰ ZHTP mesh request timeout
```

### Root Causes:
1. **UDP Socket Not Receiving Responses** - The browser sends UDP packets but gets no reply
2. **Protocol Mismatch** - Server might not be properly handling the ZHTP mesh protocol format
3. **Server Not Listening on UDP** - Unified server may be HTTP-only

### What's Working:
- ✅ ZHTP backend starts successfully
- ✅ All components initialize
- ✅ DHT client running on port 33446
- ✅ HTTP API ready on port 9333

### What's NOT Working:
- ❌ Browser → Server UDP mesh communication
- ❌ ZHTP native protocol responses
- ❌ Mesh message handling

---

## 11. SOLUTION PATH

The server needs to:
1. **Listen for UDP packets on port 9333** (in addition to TCP)
2. **Parse ZHTP mesh protocol format** from browser
3. **Route to appropriate handler** (Web4/DNS/DHT)
4. **Send UDP response back** to browser

Check `unified_server.rs` around line 3000+ for UDP mesh handler implementation!

---

## Summary

The architecture is **complete and well-designed**:
- Browser → Server: Native ZHTP mesh protocol
- Server: Unified handler with all protocols
- Web4: Domain + content management
- Blockchain: Smart contracts for ownership
- DHT: Distributed content storage
- DNS: Domain resolution

The **only issue** is the UDP mesh protocol communication between browser and server needs to be verified/fixed.
