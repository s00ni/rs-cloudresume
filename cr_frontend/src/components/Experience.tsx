import "../index.css"

function ExperienceItem ({
    company = "string",
    title = "string", 
    dates ="string",
}) {
    return(
        <div className = "resume-entry">
            <div className = "entry-title">{company}</div>
            <div className = "entry-meta">
                <div>{title}</div>
                <div style = {{color: "#8774f2" }}>{dates}</div>
            </div>
        </div>
    )
}

function EducationItem ({
    school = "string",
    degree = "string", 
    dates ="string",
}) {
    return(
        <div className = "resume-entry">
            <div className = "entry-title">{school}</div>
            <div className = "entry-meta">
                <div>{degree}</div>
                <div style = {{color: "#8774f2" }}>{dates}</div>
            </div>
        </div>
    )
}


export default function Experience () {
    return (
        <div>
            <div id="experience" className = "resume-block">
                    <p className = "heading-underline">EXPERIENCE</p>
                <section>
                    <ExperienceItem
                        company = "The World Bank"
                        title = "IT Provisioning Analyst/Global PC Maintenance"
                        dates = "July 2023 - Present"></ExperienceItem>
                    <ul>
                        <li>Troubleshooting and analyzing the status of over 50 devices by generating reliability, battery performance, and SPLUNK reports during IT expo events.</li>
                        <li>Performing proactive maintenance checks on corporate employees’ devices by analyzing high-utilization reports, coordinating calls, and applying fixes.</li>
                        <li>Organizing monthly client satisfaction meetings with the local IT, Engineering, and Global PC Maintenance teams to address recurring hardware and
                        software issues.</li>
                        <li>Streamlining resource allocation by managing the organization of devices into shared-use collections via the System Center Configuration Manager.</li>
                        <li>Ensuring prompt resolution of provisioning requests and maintaining SLAs daily (100% compliance on average).</li>
                        <li>Establishing key relationships with engineering leads, managers, and co-workers by taking on additional tasks and maintaining strong communication.</li>
                    </ul>
                </section>

                <section>
                    <ExperienceItem
                        company = "Stride Inc."
                        title = "IT Helpdesk Intern"
                        dates = "June 2021 – August 2021"></ExperienceItem>
                    <ul>
                        <li>Directed inventory reconciliation of over 150 laptops returned and deployed with Windows 10 to corporate employees and C-suite executives.</li>
                        <li>Encrypted laptops for new hires with McAfee ePolicy Orchestrator, set up personal Windows accounts, imaged new laptops, and integrated new users into
                        the active directory.</li>
                        <li>Diagnosed and troubleshooted hardware and software problems remotely through ConnectWise Automate.</li>
                    </ul>
                </section>
            </div>
            <div className = "resume-block" id= "education">
                <p className = "heading-underline">EDUCATION</p>
                <section>
                    <EducationItem
                        school = "Virginia Polytechnic Institute and State University"
                        degree = "BS Business Information Technology (Decision Support Systems)"
                        dates = "August 2017 - May 2022"></EducationItem>
                </section>
            </div>
            <div id= "skills" className = "resume-block">
                <p className = "heading-underline">SKILLS</p>
                <ul style={{paddingTop: "2rem"}}>
                    <li>Programming: Hands-on experience with SQL (MySQL), React, HTML5, CSS, and Python.</li>
                    <li>IT tools: ConnectWise Automate/Manage, ServiceNow, SPLUNK, and SCCM (System Center Configuration Manager).</li>
                    <li>Advanced Excel: VBA, Lookup Functions, Pivot Tables and Charts, Data Analysis Tools, and Optimization.</li>
                </ul>
            </div>
        </div>
    )
}