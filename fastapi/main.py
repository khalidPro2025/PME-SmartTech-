from fastapi import FastAPI, HTTPException, Depends, status, Request
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from pydantic import BaseModel
from typing import Dict
from passlib.context import CryptContext
from jose import JWTError, jwt
import socket
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware

# ------- CONFIG --------
SECRET_KEY = "change_this_secret_in_prod_!2025"  # >> CHANGE before prod (or mount as env var)
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

app = FastAPI(title="SmartTech Multiservices API with Auth")

# allow portal origin (traefik will handle hostnames). If using different host, adjust.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://portal.smarttech.local", "http://localhost:8081"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ------- demo users (replace with DB in prod) -------
fake_users_db = {
    "awa": {
        "username": "awa",
        "full_name": "Awa",
        "hashed_password": pwd_context.hash("Awapass123!"),
        "disabled": False
    },
    "khalid": {
        "username": "khalid",
        "full_name": "Khalid",
        "hashed_password": pwd_context.hash("KhalidPass123!"),
        "disabled": False
    }
}

SERVICES = {
    "dns": "dns.smarttech.local",
    "ftp": "ftp.smarttech.local",
    "ssh": "ssh.smarttech.local",
    "sip": "sip.smarttech.local",
    "mail": "mail.smarttech.local",
    "novnc": "vnc.smarttech.local",
    "samba": "smb.smarttech.local",
    "api": "api.smarttech.local",
    "portal": "portal.smarttech.local"
}

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None

class User(BaseModel):
    username: str
    full_name: str | None = None
    disabled: bool | None = None

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def authenticate_user(username: str, password: str):
    user = fake_users_db.get(username)
    if not user: return False
    if not verify_password(password, user["hashed_password"]): return False
    return User(username=username, full_name=user.get("full_name"), disabled=user.get("disabled"))

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                          detail="Could not validate credentials",
                                          headers={"WWW-Authenticate":"Bearer"})
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None: raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user_rec = fake_users_db.get(token_data.username)
    if user_rec is None:
        raise credentials_exception
    user = User(username=token_data.username, full_name=user_rec.get("full_name"))
    return user

# ---------- AUTH ENDPOINT ----------
@app.post("/auth/login", response_model=Token)
async def login(form_data: Request):
    """
    Accepts JSON body: { "username": "...", "password": "..." } or form data.
    Returns JWT access_token.
    """
    data = await form_data.json() if form_data.headers.get("content-type","").startswith("application/json") else await form_data.form()
    username = data.get("username")
    password = data.get("password")
    user = authenticate_user(username, password)
    if not user:
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    access_token = create_access_token({"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}

# ---------- PUBLIC ENDPOINTS ----------
@app.get("/")
def root():
    return {"message": "SmartTech API (auth-enabled)"}

@app.get("/services")
def list_services():
    return SERVICES

# ---------- PROTECTED ENDPOINT ----------
@app.get("/services/status/{name}")
async def service_status(name: str, current_user: User = Depends(get_current_user)):
    host = SERVICES.get(name)
    if not host:
        raise HTTPException(status_code=404, detail="Service not found")
    try:
        socket.gethostbyname(host)
        return {"service": name, "host": host, "status": "UP"}
    except Exception as e:
        return {"service": name, "host": host, "status": "DOWN", "error": str(e)}
