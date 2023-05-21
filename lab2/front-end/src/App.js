import logo from './logo.svg';
import './App.css';
import { useState, useEffect } from "react"
import axios from "axios";



function App() {
  const API = "http://localhost:7000/api/";


  const [ email, setEmail ] = useState("");
  const [ password, setPassword ] = useState("");

  const [ user, setUser ] = useState("none");

  const [ items, setItems ] = useState([]);

  useEffect(() => {
    const userId = localStorage.getItem("userId");
    if (userId) {
      axios.get(API + "auth/user/" + userId)
        .then((response) => {
          setUser(response.data.email);
        });
      
      axios.get(API + "items/" + userId)
        .then((response) => {
          setItems(response.data);
          console.log('response', response)
          
        });
        
    }
    else {
      setUser("none");
      setItems([]);
    }
  }, [])


  async function login() {
    axios.post(API + "auth/login", {email: email, password: password})
      .then((response) => {
        localStorage.setItem("userId", response.data.id);
        setUser(email);
        setEmail("");
        setPassword("");
        alert(response.data.message);
        window.location.reload(true);
      })
      .catch((err) => {
        console.log('err', err)
        alert(err.response.data.error);
        setPassword("");
      })
  }

  async function register() {
    axios.post(API + "auth/register", {email: email, password: password})
      .then((response) => {
        localStorage.setItem("userId", response.data.id);
        setUser(email);
        setEmail("");
        setPassword("");
        alert(response.data.message);
        window.location.reload(true);
      })
      .catch((err) => {
        alert(err.response.data.error);
        setPassword("");
      })
  }

  function logout() {
    setUser("none");
    localStorage.removeItem("userId");
    window.location.reload(true);
  }

  function changeViewed(val, id) {
    axios.put(API + `items/viewed/${val}/${id}`, {})
    window.location.reload(true);
  }

  function handleChange(e, prop, index)  {
    let updatedValue = {};
    updatedValue[prop] = e.target.value;
    
    let newArr = [...items];
    newArr[index] = ({
      ...newArr[index],
      ...updatedValue
    })

    setItems(newArr);
  }

  function onCreate() {
    axios.post(API + "items/", {userId: localStorage.getItem("userId")})
      .then(response => {
        window.location.reload(true);
      })
      .catch((error) =>{
        alert("Error:" + error);
      });
  }

  function onUpdate(index) {
    const item = items[index];
    axios.put(API + "items/" + item.id, item)
      .then(response => {
        alert("Updated");
        window.location.reload(true);
      })
      .catch((error) =>{
        alert("Error:" + error);
      });
  }

  function onDelete(index) {
    const item = items[index];
    axios.delete(API + "items/" + item.id)
      .then(response => {
        alert("Deleted");
        window.location.reload(true);
      })
      .catch((error) =>{
        alert("Error:" + error);
      });
  }

  return (
    <>
      <nav className="navbar bg-body-tertiary">
        <div className="container-fluid">
          <a className="navbar-brand" href='#main'>Company name</a>
          <div className="d-flex mx-5 my-3">
            <h5>{"Logined as: " + user}</h5>
          </div>
        </div>
      </nav>
      <div className="container text-center">
        <div className="row text-center">
          <div className='col'>
            <h3>#ItemsToWatch</h3>
            {items.length === 0 ?
               (<p>No items found. Add new now!</p>) : 
               (<p>All your saved items listed</p>) 
            }

            <button
              className='btn btn-outline-warning px-5 py-3 m-4'
              onClick={onCreate}>Add new item</button>
          </div>
        </div>

        <div className="row row-cols-3 ">
          <div className='col col-sm-1'></div>
          <div className='col col-sm-10 text-start'>
            {items.map((item, i) => 
              <div className="card my-2" key={i}>
                <div className="card-header row m-0 justify-content-between">
                  <div className='col-6 align-middle'>{item.name + " | " + (item.viewed ? "viewed" : "not viewed")}</div>
                  <div className='col-2'>
                    <button 
                      className={item.viewed ? "btn btn-outline-success" : "btn btn-outline-danger"}
                      onClick={() => changeViewed(item.viewed ? 0 : 1, item.id)}>
                      {item.viewed ? "Make not viewed" : "Make viewed"}
                    </button>
                  </div>
                </div>
                <div className="card-body">
                  <div className='row'>
                    <div className='col-auto'>
                      <img src={item.cover} alt='cover' style={{width:300}}></img>
                    </div>
                    <div className='col'>
                      <label className="form-label">Name:</label>
                      <input 
                        className="form-control" 
                        onChange={(e) => handleChange(e, "name", i)}
                        value={item.name}/>

                      <label className="form-label">Director:</label>
                      <input 
                        className="form-control" 
                        onChange={(e) => handleChange(e, "director", i)}
                        value={item.director}/>

                      <label className="form-label">Cover:</label>
                      <input 
                        className="form-control" 
                        onChange={(e) => handleChange(e, "cover", i)}
                        value={item.cover}/>

                      <label className="form-label">Type:</label>
                      <select
                        className="form-control" 
                        onChange={(e) => handleChange(e, "type", i)}
                        value={item.type}>
                        <option>film</option>
                        <option>series</option>
                        <option>cartoon</option>
                        <option>animation</option>
                      </select>

                      <label className="form-label">Rating:</label>
                      <select
                        className="form-control" 
                        onChange={(e) => handleChange(e, "rate", i)}
                        value={item.rate}>
                        <option value={0}>0</option>
                        <option value={1}>1</option>
                        <option value={2}>2</option>
                        <option value={3}>3</option>
                        <option value={4}>4</option>
                        <option value={5}>5</option>
                      </select>

                      <label className="form-label">Description:</label>
                      <textarea 
                        rows="5"
                        className="form-control" 
                        onChange={(e) => handleChange(e, "description", i)}
                        value={item.description}/>
                    </div>
                  </div>
                </div>
                <div className='card-footer'>
                  <button 
                    className='btn btn-outline-warning mx-5'
                    onClick={() => onDelete(i)}>Delete</button>
                  <button 
                    className='btn btn-outline-warning mx-5'
                    onClick={() => onUpdate(i)}>Update</button>
                </div>
              </div>
            )}
          </div>
          <div className='col col-sm-1'></div>
        </div>

        <div className="row text-center">
          <div className='col'>
            <h3>Login / Register section</h3>
            <p>input your credentials and log in or register in the system</p>
          </div>
        </div>
        <div className="row row-cols-3">
          <div className='col'></div>
          <div className='col'>
            <label className="form-label my-3">Email:</label>
            <input 
              className="form-control" 
              onChange={(e) => setEmail(e.target.value)}
              value={email}/>

            <label  className="form-label my-3">Password:</label>
            <input 
              type="password" 
              className="form-control" 
              onChange={(e) => setPassword(e.target.value)}
              value={password}/>

            <button 
              className="btn btn-outline-warning m-3"
              onClick={login}>Login</button>
            <button 
              className="btn btn-outline-warning m-3"
              onClick={register}>Register</button>
            <button 
              className="btn btn-outline-warning m-3"
              onClick={logout}>Logout</button>
          </div>
          <div className='col'></div>
        </div>
      </div>
    </>
  );
}

export default App;
