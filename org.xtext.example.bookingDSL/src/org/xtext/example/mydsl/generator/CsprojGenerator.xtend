package org.xtext.example.mydsl.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.emf.ecore.resource.Resource
import org.xtext.example.mydsl.bookingDSL.*;

class CsprojGenerator {
	static def void generateCSProjFile(IFileSystemAccess2 fsa,
		Resource resource)
	{
		var systemName = resource.allContents.toList.filter(System).get(0).getName();
		
		fsa.generateFile('''«systemName»/«systemName»/«systemName».csproj''', 
			'''
			<Project Sdk="Microsoft.NET.Sdk.Web">
			
			    <PropertyGroup>
			        <TargetFramework>netcoreapp3.1</TargetFramework>
			        <TypeScriptCompileBlocked>true</TypeScriptCompileBlocked>
			        <TypeScriptToolsVersion>Latest</TypeScriptToolsVersion>
			        <IsPackable>false</IsPackable>
			        <SpaRoot>ClientApp\</SpaRoot>
			        <DefaultItemExcludes>$(DefaultItemExcludes);$(SpaRoot)node_modules\**</DefaultItemExcludes>
			    </PropertyGroup>
			
			    <ItemGroup>
			    	<PackageReference Include="AutoMapper" Version="10.1.1" />
			        <PackageReference Include="Microsoft.AspNetCore.SpaServices.Extensions" Version="3.1.9" />
			        <PackageReference Include="MongoDB.Driver" Version="2.12.1" />
			        <PackageReference Include="Swashbuckle.AspNetCore" Version="6.1.2" />
			    </ItemGroup>
			
			    <ItemGroup>
			        <!-- Don't publish the SPA source files, but do show them in the project files list -->
			        <Content Remove="$(SpaRoot)**" />
			        <None Remove="$(SpaRoot)**" />
			        <None Include="$(SpaRoot)**" Exclude="$(SpaRoot)node_modules\**" />
			    </ItemGroup>
			
			    <Target Name="DebugEnsureNodeEnv" BeforeTargets="Build" Condition=" '$(Configuration)' == 'Debug' And !Exists('$(SpaRoot)node_modules') ">
			        <!-- Ensure Node.js is installed -->
			        <Exec Command="node --version" ContinueOnError="true">
			            <Output TaskParameter="ExitCode" PropertyName="ErrorCode" />
			        </Exec>
			        <Error Condition="'$(ErrorCode)' != '0'" Text="Node.js is required to build and run this project. To continue, please install Node.js from https://nodejs.org/, and then restart your command prompt or IDE." />
			        <Message Importance="high" Text="Restoring dependencies using 'npm'. This may take several minutes..." />
			        <Exec WorkingDirectory="$(SpaRoot)" Command="npm install" />
			    </Target>
			
			    <Target Name="PublishRunWebpack" AfterTargets="ComputeFilesToPublish">
			        <!-- As part of publishing, ensure the JS resources are freshly built in production mode -->
			        <Exec WorkingDirectory="$(SpaRoot)" Command="npm install" />
			        <Exec WorkingDirectory="$(SpaRoot)" Command="npm run build" />
			
			        <!-- Include the newly-built files in the publish output -->
			        <ItemGroup>
			            <DistFiles Include="$(SpaRoot)build\**" />
			            <ResolvedFileToPublish Include="@(DistFiles->'%(FullPath)')" Exclude="@(ResolvedFileToPublish)">
			                <RelativePath>%(DistFiles.Identity)</RelativePath>
			                <CopyToPublishDirectory>PreserveNewest</CopyToPublishDirectory>
			                <ExcludeFromSingleFile>true</ExcludeFromSingleFile>
			            </ResolvedFileToPublish>
			        </ItemGroup>
			    </Target>
			
			</Project>
			''')
	}
}