import java.io.File;

import javax.inject.Inject;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;

import static org.daisy.pipeline.pax.exam.Options.calabashConfigFile;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;
import static org.daisy.pipeline.pax.exam.Options.xprocspecBundles;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertTrue;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.wrappedBundle;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class NordicEpub3DtbookMigratorTest {
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			calabashConfigFile(),
			logbackBundles(),
			felixDeclarativeServices(),
			pipelineModule("asciimath-utils"),
			pipelineModule("common-utils"),
			pipelineModule("dtbook-utils"),
			pipelineModule("dtbook-validator"),
			pipelineModule("epub3-nav-utils"),
			pipelineModule("epub3-ocf-utils"),
			pipelineModule("epub3-pub-utils"),
			pipelineModule("epubcheck-adapter"),
			pipelineModule("file-utils"),
			pipelineModule("fileset-utils"),
			pipelineModule("html-utils"),
			pipelineModule("mediaoverlay-utils"),
			pipelineModule("mediatype-utils"),
			pipelineModule("validation-utils"),
			pipelineModule("zip-utils"),
			mavenBundle().groupId("org.idpf").artifactId("epubcheck").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.apache.commons").artifactId("commons-compress").versionAsInProject(),
			// [mvn:org.tukaani/xz/1.0] is not a valid bundle
			wrappedBundle(mavenBundle().groupId("org.tukaani").artifactId("xz").versionAsInProject()),
			// we need two versions of guava, 15.0 for the pipeline framework and 13.0.1 for epubcheck
			mavenBundle().groupId("com.google.guava").artifactId("guava").version("13.0.1"),
			// we need two versions of saxon, 9.5.1.5 for the pipeline framework and 9.4.0.6 for epubcheck.
			// the epubcheck bundle accepts both versions but only actually works with 9.4. this can
			// be solved giving 9.4 a lower start level, because bundles installed first are used to
			// satisfy a dependency when multiple packages with the same version are found.
			mavenBundle().groupId("org.daisy.libs").artifactId("saxon-he").version("9.4.0.7").startLevel(1),
			xprocspecBundles(),
			junitBundles()
		);
	}
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
	
	@Test
	public void runXProcSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		boolean success = xprocspecRunner.run(new File(baseDir, "src/test/xprocspec"),
		                                      new File(baseDir, "target/xprocspec-reports"),
		                                      new File(baseDir, "target/surefire-reports"),
		                                      new File(baseDir, "target/xprocspec"),
		                                      new XProcSpecRunner.Reporter.DefaultReporter());
		assertTrue("XProcSpec tests should run with success", success);
	}
}
