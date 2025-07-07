import  SocialMedia from "./SocialMedia"
import "../index.css"
import Fetch from './Fetch'


function About() {
    return(
    <div className = "about-section">
        <p>I am an IT analyst based in Northern Virginia who is actively pivoting into Cloud engineering. <br/>
            I’m always searching for new ways to deepen my Cloud knowledge through hands-on projects. <br/>
            Check out my stuff below!
        </p> 
    </div>
    )
}

export default function Hero() {
    return(
    <div className="intro-wrapper">
        <div className="hero-section">
            <h1 style={{fontWeight: "500"}}>Hi! I'm Rachel Soon</h1> 
            <span style={{fontWeight: "100", color: "#CDBFFB"}}>and this page has been viewed <Fetch /> times</span>
            <SocialMedia/>
        </div>
        <div>
            <About/>
        </div>
    </div>
    )
}
