package org.xtext.example.mydsl.generator.ClientAppGenerators

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.emf.ecore.resource.Resource
import org.xtext.example.mydsl.bookingDSL.Customer
import org.xtext.example.mydsl.bookingDSL.Entity
import org.xtext.example.mydsl.bookingDSL.Schedule
import org.xtext.example.mydsl.bookingDSL.Declaration
import org.xtext.example.mydsl.bookingDSL.Booking

class ComponentsGenerator {
	
	private IFileSystemAccess2 fsa;
	private Resource resource;
	private String componentsRoot;
	
	new(IFileSystemAccess2 fsa, Resource resource, String srcRoot) {
		this.fsa = fsa;
		this.resource = resource;
		this.componentsRoot = srcRoot + "/components";
	}
	
	def importDeclaration(Declaration declaration) {
		switch declaration {
			Booking: { null }
			default: {
				return '''
				import «declaration.name»sOverviewPage from '../pages/management/«declaration.name»/«declaration.name»sOverviewPage';
				import Update«declaration.name»Page from '../pages/management/«declaration.name»/Update«declaration.name»Page';
				import Create«declaration.name»Page from '../pages/management/«declaration.name»/Create«declaration.name»Page';
				'''
			}
		}
	}
	
	def createDynamicUrls(Declaration declaration) {
		switch declaration {
			Booking: { null }
			default: {
				return '''
				<Route exact path="/management/«declaration.name»s_overview" component={«declaration.name»sOverviewPage}/>
		      	<Route exact path="/management/«declaration.name»_update/:id" component={Update«declaration.name»Page}/>
		      	<Route exact path="/management/«declaration.name»_create" component={Create«declaration.name»Page}/>
				'''
			}	
		}
	}
	
	def generate() {
		this.fsa.generateFile(this.componentsRoot + "/App.tsx", '''
		import React, { Component } from 'react';
		import { Redirect, Route, Switch } from 'react-router';
		import { BrowserRouter as Router} from 'react-router-dom';
		import LoginPage from '../pages/LoginPage';
		import BookingPage from '../pages/BookingPage';
		import ResourceOverviewPage from '../pages/management/ResourceOverviewPage';
		import UserPage from '../pages/UserPage';
		import BookingOverviewPage from '../pages/BookingOverviewPage';
		«FOR declaration : resource.allContents.toList.filter(Declaration)»
		«importDeclaration(declaration)»
		«ENDFOR»
		
		const App = () => {
		
		  const render = () => {
		    return <Router>
		      <Switch>
		      	«FOR declaration : resource.allContents.toList.filter(Declaration)»
		      	«createDynamicUrls(declaration)»
		      	«ENDFOR»
		      	<Route exact path="/management/overview" component={ResourceOverviewPage}/>
		        <Route exact path="/booking/:id/:type" component={BookingPage}/>
		        <Route exact path="/userpage/:id/:type" component={UserPage}/>
        		<Route exact path="/bookingoverview/:id/:type" component={BookingOverviewPage}/>
        		<Route exact path="/login" component={LoginPage}/>
        		<Redirect to="/login"/>
		      </Switch>
		    </Router>
		  }
		
		  return render();
		
		}
		
		export default App;
		''')
		
		this.fsa.generateFile(this.componentsRoot + "/Chiplist.tsx", '''
		import { Chip, makeStyles, Theme, Typography } from "@material-ui/core";
		import { Cancel } from "@material-ui/icons";
		import React from "react";
		
		const useStyles = makeStyles((theme: Theme) => ({
		    chipContainer: {
		        "backgroundColor": "transparent",
		        "display": "inline-block",
		        "marginBottom": "20px"
		    },
		    chip: {
		        "marginTop": "10px",
		        "marginRight": "5px"
		    }
		}))
		
		interface ChipListProps {
		    selectedItems: string[]
		    onRemoveItem: (item: string) => void;
		    title?: string
		}
		
		const ChipList = (props: ChipListProps) => {
		
		    const classes = useStyles();
		
		    const {selectedItems, onRemoveItem, title} = props;
		
		    const render = () => {
		        return (
		            <div className={classes.chipContainer}>
		                {selectedItems.length > 0 ?
		                    <div>
		                        <Typography>{title}:</Typography>
		                        {selectedItems.map((item, key) => {
		                            return <Chip
		                                key={key}
		                                className={classes.chip}
		                                label={item}
		                                deleteIcon={<Cancel/>}
		                                onDelete={() => onRemoveItem(item)}
		                                onClick={() => onRemoveItem(item)}
		                            />
		                        })}
		                    </div> : null
		                }
		            </div>
		        )
		    }
		
		    return render();
		}
		
		export default ChipList;
		
		''')
	}
}